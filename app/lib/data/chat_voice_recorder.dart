import 'chat_attachment_picker.dart';

/// Records a short voice clip for agent chat.
abstract class ChatVoiceRecorder {
  /// Whether a recording session is active.
  bool get isRecording;

  /// Starts a new recording. No-op if already recording.
  ///
  /// Throws [ChatVoicePermissionException] when the microphone is denied.
  Future<void> start();

  /// Stops recording and returns the captured file, or null if cancelled /
  /// too short / failed.
  Future<PickedChatFile?> stop();

  /// Cancels without producing a file.
  Future<void> cancel();

  /// Releases native resources.
  Future<void> dispose();
}

/// Thrown when the microphone permission is denied.
final class ChatVoicePermissionException implements Exception {
  const ChatVoicePermissionException();

  @override
  String toString() => 'ChatVoicePermissionException';
}
