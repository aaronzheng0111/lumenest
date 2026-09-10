import 'package:flutter/foundation.dart';

import '../chat/chat_media.dart';
import '../chat/chat_outgoing.dart';
import 'chat_attachment_picker.dart';
import 'chat_voice_recorder.dart';
import 'local_chat_media_store.dart';

/// Owns pending attachments + voice recording for a chat session page.
class ChatComposerMediaController extends ChangeNotifier {
  ChatComposerMediaController({
    required ChatAttachmentPicker picker,
    required ChatVoiceRecorder recorder,
    required LocalChatMediaStore store,
  })  : _picker = picker,
        _recorder = recorder,
        _store = store;

  final ChatAttachmentPicker _picker;
  final ChatVoiceRecorder _recorder;
  final LocalChatMediaStore _store;

  final List<ChatMediaItem> _pending = [];
  bool _recording = false;
  bool _busy = false;

  List<ChatMediaItem> get pending => List.unmodifiable(_pending);
  bool get isRecording => _recording;
  bool get isBusy => _busy;

  /// Opens the system picker and imports selected files into local storage.
  Future<ChatMediaAttachResult> attachFiles() async {
    if (_busy || _recording) return ChatMediaAttachResult.busy;
    if (!ChatMediaLimits.canAddMore(_pending.length)) {
      return ChatMediaAttachResult.tooMany;
    }
    _busy = true;
    notifyListeners();
    try {
      final picked = await _picker.pickAttachments();
      if (picked.isEmpty) return ChatMediaAttachResult.cancelled;

      for (final file in picked) {
        if (!ChatMediaLimits.canAddMore(_pending.length)) {
          return ChatMediaAttachResult.tooMany;
        }
        try {
          final item = await _store.importFile(
            sourcePath: file.path,
            displayName: file.displayName,
            kind: file.kind,
          );
          _pending.add(item);
        } on ChatMediaTooLargeException {
          notifyListeners();
          return ChatMediaAttachResult.tooLarge;
        }
      }
      return ChatMediaAttachResult.ok;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Toggles voice recording. When stopping, imports the clip as pending audio
  /// and returns [ChatVoiceToggleResult.readyToSend] so the page can auto-send
  /// when the text field is empty.
  Future<ChatVoiceToggleResult> toggleVoice() async {
    if (_busy) return ChatVoiceToggleResult.busy;
    if (_recording) {
      _busy = true;
      notifyListeners();
      try {
        final picked = await _recorder.stop();
        _recording = false;
        if (picked == null) {
          return ChatVoiceToggleResult.tooShort;
        }
        if (!ChatMediaLimits.canAddMore(_pending.length)) {
          return ChatVoiceToggleResult.tooMany;
        }
        try {
          final item = await _store.importFile(
            sourcePath: picked.path,
            displayName: picked.displayName,
            kind: ChatMediaKind.audio,
          );
          _pending.add(item);
          return ChatVoiceToggleResult.readyToSend;
        } on ChatMediaTooLargeException {
          return ChatVoiceToggleResult.tooLarge;
        }
      } finally {
        _busy = false;
        notifyListeners();
      }
    }

    try {
      await _recorder.start();
      _recording = true;
      notifyListeners();
      return ChatVoiceToggleResult.started;
    } on ChatVoicePermissionException {
      return ChatVoiceToggleResult.permissionDenied;
    } catch (e, st) {
      debugPrint('voice start failed: $e\n$st');
      return ChatVoiceToggleResult.failed;
    }
  }

  void removePending(String id) {
    _pending.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Builds a send payload from [text] + pending media, then clears pending.
  ChatOutgoingPayload takeOutgoing(String text) {
    final payload = ChatOutgoing.build(text: text, media: _pending);
    _pending.clear();
    notifyListeners();
    return payload;
  }

  bool canSend(String text) {
    final payload = ChatOutgoing.build(text: text, media: _pending);
    return !payload.isEmpty;
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }
}

enum ChatMediaAttachResult {
  ok,
  cancelled,
  tooLarge,
  tooMany,
  busy,
}

enum ChatVoiceToggleResult {
  started,
  readyToSend,
  tooShort,
  tooLarge,
  tooMany,
  permissionDenied,
  failed,
  busy,
}
