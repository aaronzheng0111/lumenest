import 'dart:convert';

/// Local chat attachment metadata persisted via [Messages.imageRef].
enum ChatMediaKind {
  image,
  file,
  audio,
}

/// One pending or persisted media attachment for an agent chat message.
final class ChatMediaItem {
  const ChatMediaItem({
    required this.id,
    required this.kind,
    required this.localPath,
    required this.displayName,
    this.sizeBytes,
  });

  final String id;
  final ChatMediaKind kind;
  final String localPath;
  final String displayName;
  final int? sizeBytes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'localPath': localPath,
        'displayName': displayName,
        if (sizeBytes != null) 'sizeBytes': sizeBytes,
      };

  static ChatMediaItem fromJson(Map<String, dynamic> json) {
    return ChatMediaItem(
      id: json['id'] as String,
      kind: ChatMediaKind.values.byName(json['kind'] as String),
      localPath: json['localPath'] as String,
      displayName: json['displayName'] as String,
      sizeBytes: json['sizeBytes'] as int?,
    );
  }

  /// Encodes [items] for the Drift `image_ref` column.
  static String? encodeList(List<ChatMediaItem> items) {
    if (items.isEmpty) return null;
    return jsonEncode(items.map((e) => e.toJson()).toList());
  }

  /// Decodes a Drift `image_ref` payload into media items.
  static List<ChatMediaItem> decodeList(String? raw) {
    if (raw == null) return const [];
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const [];
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => ChatMediaItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on FormatException {
      return const [];
    }
  }
}

/// Size / count limits for chat attachments (aligned with sdd/14 image cap).
abstract final class ChatMediaLimits {
  static const maxBytes = 4 * 1024 * 1024;
  static const maxAttachments = 5;

  static ChatMediaValidation validateSize(int bytes) {
    if (bytes > maxBytes) return ChatMediaValidation.tooLarge;
    return ChatMediaValidation.ok;
  }

  static bool canAddMore(int currentCount) => currentCount < maxAttachments;
}

enum ChatMediaValidation { ok, tooLarge }

/// Thrown when an imported file exceeds [ChatMediaLimits.maxBytes].
final class ChatMediaTooLargeException implements Exception {
  const ChatMediaTooLargeException();

  @override
  String toString() => 'ChatMediaTooLargeException';
}
