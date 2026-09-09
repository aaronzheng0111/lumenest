/// Builds OpenAI-compatible chat completions URL (Plan · 06).
String buildChatCompletionsUrl(String baseUrl) {
  var base = baseUrl.trim().replaceAll(RegExp(r'/$'), '');
  if (base.endsWith('/v1')) {
    return '$base/chat/completions';
  }
  return '$base/v1/chat/completions';
}

enum LlmStatus {
  ok,
  timeout,
  httpError,
  parseError,
  missingKey,
}

class ChatMessageWire {
  const ChatMessageWire({required this.role, required this.content});

  final String role; // system | user | assistant
  final String content;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class LlmResult {
  const LlmResult({
    required this.status,
    this.content,
    this.promptTokens,
    this.completionTokens,
    this.httpStatus,
    this.latencyMs,
  });

  final LlmStatus status;
  final String? content;
  final int? promptTokens;
  final int? completionTokens;
  final int? httpStatus;
  final int? latencyMs;

  bool get isOk => status == LlmStatus.ok && content != null;
}

/// Fixed user-facing copy (AC-06-F01 / B04). Mapped by chat/agent layer.
abstract final class LlmUserCopy {
  static const retryLater = '稍后再试';
  static const missingKey = '未配置模型服务';
  static const loading = '正在回复';
}

/// OpenAI-style stream event: zero or more text [LlmStreamDelta]s, then one [LlmStreamEnd].
sealed class LlmStreamEvent {
  const LlmStreamEvent();
}

/// Incremental token (or coalesced chunk) from a streaming completion.
final class LlmStreamDelta extends LlmStreamEvent {
  const LlmStreamDelta(this.text);

  final String text;
}

/// Terminal event for a streaming completion (success or error).
final class LlmStreamEnd extends LlmStreamEvent {
  const LlmStreamEnd(this.result);

  final LlmResult result;
}

abstract class LlmClient {
  /// When false, the agent graph uses [OfflineDefaultReply] instead of remote LLM.
  bool get canCallRemote => true;

  Future<LlmResult> complete({
    required List<ChatMessageWire> messages,
    required String requestId,
  });

  /// Streaming chat completion. Default: one-shot [complete], then one delta + end.
  Stream<LlmStreamEvent> streamComplete({
    required List<ChatMessageWire> messages,
    required String requestId,
  }) =>
      oneShotLlmStream(this, messages: messages, requestId: requestId);
}

/// Default [LlmClient.streamComplete]: await [LlmClient.complete], emit one delta + end.
Stream<LlmStreamEvent> oneShotLlmStream(
  LlmClient client, {
  required List<ChatMessageWire> messages,
  required String requestId,
}) async* {
  final result = await client.complete(
    messages: messages,
    requestId: requestId,
  );
  if (result.isOk && (result.content?.isNotEmpty ?? false)) {
    yield LlmStreamDelta(result.content!);
  }
  yield LlmStreamEnd(result);
}

/// Consumes [streamComplete] into a final [LlmResult], invoking [onPartial]
/// with the accumulated assistant text after each delta.
Future<LlmResult> collectLlmStream(
  Stream<LlmStreamEvent> stream, {
  void Function(String partial)? onPartial,
}) async {
  final buffer = StringBuffer();
  LlmResult? ended;
  await for (final event in stream) {
    switch (event) {
      case LlmStreamDelta(:final text):
        if (text.isEmpty) continue;
        buffer.write(text);
        onPartial?.call(buffer.toString());
      case LlmStreamEnd(:final result):
        ended = result;
    }
  }
  if (ended == null) {
    return const LlmResult(status: LlmStatus.parseError);
  }
  if (ended.status == LlmStatus.ok &&
      (ended.content == null || ended.content!.isEmpty) &&
      buffer.isNotEmpty) {
    return LlmResult(
      status: LlmStatus.ok,
      content: buffer.toString(),
      promptTokens: ended.promptTokens,
      completionTokens: ended.completionTokens,
      httpStatus: ended.httpStatus,
      latencyMs: ended.latencyMs,
    );
  }
  return ended;
}
