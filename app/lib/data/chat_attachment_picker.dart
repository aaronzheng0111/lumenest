import '../chat/chat_media.dart';

/// A file chosen by the user before it is imported into local storage.
final class PickedChatFile {
  const PickedChatFile({
    required this.path,
    required this.displayName,
    required this.kind,
  });

  final String path;
  final String displayName;
  final ChatMediaKind kind;
}

/// Picks files or images for the chat composer.
abstract class ChatAttachmentPicker {
  Future<List<PickedChatFile>> pickAttachments();
}
