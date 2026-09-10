import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../chat/chat_media.dart';
import 'chat_attachment_picker.dart';

typedef PickChatFiles = Future<FilePickerResult?> Function({
  bool allowMultiple,
  FileType type,
  bool withData,
});

/// [file_picker]-backed attachment source for agent chat.
class FilePickerChatAttachmentPicker implements ChatAttachmentPicker {
  FilePickerChatAttachmentPicker({PickChatFiles? pickFiles})
      : _pickFiles = pickFiles ??
            (({
              bool allowMultiple = false,
              FileType type = FileType.any,
              bool withData = false,
            }) =>
                FilePicker.pickFiles(
                  allowMultiple: allowMultiple,
                  type: type,
                  withData: withData,
                ));

  final PickChatFiles _pickFiles;

  @override
  Future<List<PickedChatFile>> pickAttachments() async {
    final result = await _pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return const [];

    final out = <PickedChatFile>[];
    for (final file in result.files) {
      final path = file.path;
      if (path == null || path.isEmpty) continue;
      final name = file.name.isNotEmpty ? file.name : p.basename(path);
      out.add(
        PickedChatFile(
          path: path,
          displayName: name,
          kind: kindForName(name),
        ),
      );
    }
    return out;
  }

  /// Maps a file name extension to a [ChatMediaKind].
  static ChatMediaKind kindForName(String name) {
    final ext = p.extension(name).toLowerCase();
    const images = {'.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic'};
    const audio = {'.m4a', '.aac', '.mp3', '.wav', '.ogg', '.caf'};
    if (images.contains(ext)) return ChatMediaKind.image;
    if (audio.contains(ext)) return ChatMediaKind.audio;
    return ChatMediaKind.file;
  }
}
