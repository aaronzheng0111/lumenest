import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;

import '../chat/chat_media.dart';

/// Copies picked / recorded files into app-local storage for chat.
class LocalChatMediaStore {
  LocalChatMediaStore({
    required Future<Directory> Function() rootDirectory,
    String Function()? idFactory,
  })  : _rootDirectory = rootDirectory,
        _idFactory = idFactory ?? _defaultId;

  final Future<Directory> Function() _rootDirectory;
  final String Function() _idFactory;

  static String _defaultId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final rand = Random().nextInt(1 << 20);
    return '${now}_$rand';
  }

  /// Imports [sourcePath] into the media store.
  ///
  /// Throws [ChatMediaTooLargeException] when the file exceeds limits.
  Future<ChatMediaItem> importFile({
    required String sourcePath,
    required String displayName,
    required ChatMediaKind kind,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException('Source file missing', sourcePath);
    }
    final length = await source.length();
    if (ChatMediaLimits.validateSize(length) == ChatMediaValidation.tooLarge) {
      throw const ChatMediaTooLargeException();
    }

    final root = await _rootDirectory();
    final dir = Directory(p.join(root.path, 'chat_media'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final id = _idFactory();
    final ext = p.extension(displayName);
    final destName = ext.isEmpty ? id : '$id$ext';
    final destPath = p.join(dir.path, destName);
    await source.copy(destPath);

    return ChatMediaItem(
      id: id,
      kind: kind,
      localPath: destPath,
      displayName: displayName,
      sizeBytes: length,
    );
  }
}
