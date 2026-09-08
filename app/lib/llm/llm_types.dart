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

abstract class LlmClient {
  Future<LlmResult> complete({
    required List<ChatMessageWire> messages,
    required String requestId,
  });
}
