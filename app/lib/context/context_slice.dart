import '../data/conversation_repository.dart';
import '../llm/llm_types.dart';

/// Assembled context for one agent turn (sdd/09).
class ContextSlice {
  const ContextSlice({
    required this.promptBlock,
    this.recentTurns = const [],
  });

  /// Fixed-title block: 【档案】/【习惯】/【近期摘要】.
  final String promptBlock;

  /// Up to 20 prior user+assistant turns (excludes the current user utterance).
  /// Assistant turns are speaker-labeled when [ChatMessage.speakerRole] is set
  /// (shared-model multi-agent / GROUP consult).
  final List<ChatMessageWire> recentTurns;
}

abstract class ContextSlicer {
  Future<ContextSlice> build({
    required int userId,
    required int conversationId,
  });
}

abstract class SummaryWriter {
  Future<void> writeTurnSummary({
    required int userId,
    required String assistantContent,
    required String rawRef,
  });

  /// Deletes SUMMARY profile_events; leaves chat messages intact (AC-09-F01).
  Future<void> clearSummaries({required int userId});
}

/// P1 summary: rule truncate (AC-09-B03).
String truncateSummary(String content, {int maxChars = 80}) {
  final t = content.trim();
  if (t.length <= maxChars) return t;
  return t.substring(0, maxChars);
}

/// Formats one history bubble for a shared LLM transcript.
/// User text stays raw; assistants become `小暖：…` so one model can tell speakers apart.
String formatHistoryContent(ChatMessage message) {
  if (!message.isAssistant) return message.content;
  final name = message.speakerDisplayName;
  if (name == null || name.isEmpty) return message.content;
  return '$name：${message.content}';
}
