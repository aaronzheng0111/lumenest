import 'chat_media.dart';

/// Builds the text + mediaRef payload for a user chat turn.
abstract final class ChatOutgoing {
  static const voicePlaceholder = '[语音]';
  static const filePlaceholderPrefix = '[附件]';

  static ChatOutgoingPayload build({
    required String text,
    required List<ChatMediaItem> media,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty && media.isEmpty) {
      return const ChatOutgoingPayload(content: '', mediaRef: null);
    }

    final content = trimmed.isNotEmpty ? trimmed : _placeholderFor(media);

    return ChatOutgoingPayload(
      content: content,
      mediaRef: ChatMediaItem.encodeList(media),
    );
  }

  static String _placeholderFor(List<ChatMediaItem> media) {
    if (media.every((m) => m.kind == ChatMediaKind.audio)) {
      return voicePlaceholder;
    }
    if (media.length == 1) {
      return '$filePlaceholderPrefix ${media.first.displayName}';
    }
    return '$filePlaceholderPrefix ${media.length} 个文件';
  }
}

/// Result of [ChatOutgoing.build].
final class ChatOutgoingPayload {
  const ChatOutgoingPayload({
    required this.content,
    required this.mediaRef,
  });

  final String content;
  final String? mediaRef;

  bool get isEmpty => content.isEmpty && mediaRef == null;
}
