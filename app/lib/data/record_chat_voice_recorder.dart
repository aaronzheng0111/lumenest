import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../chat/chat_media.dart';
import 'chat_attachment_picker.dart';
import 'chat_voice_recorder.dart';

/// [record]-backed voice capture for agent chat.
class RecordChatVoiceRecorder implements ChatVoiceRecorder {
  RecordChatVoiceRecorder({
    AudioRecorder? recorder,
    Future<Directory> Function()? tempDirectory,
    Duration minDuration = const Duration(milliseconds: 400),
  })  : _recorder = recorder ?? AudioRecorder(),
        _tempDirectory = tempDirectory ?? getTemporaryDirectory,
        _minDuration = minDuration;

  final AudioRecorder _recorder;
  final Future<Directory> Function() _tempDirectory;
  final Duration _minDuration;

  String? _path;
  DateTime? _startedAt;
  bool _recording = false;

  @override
  bool get isRecording => _recording;

  @override
  Future<void> start() async {
    if (_recording) return;
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw const ChatVoicePermissionException();
    }
    final dir = await _tempDirectory();
    final path = p.join(
      dir.path,
      'chat_voice_${DateTime.now().microsecondsSinceEpoch}.m4a',
    );
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    _path = path;
    _startedAt = DateTime.now();
    _recording = true;
  }

  @override
  Future<PickedChatFile?> stop() async {
    if (!_recording) return null;
    _recording = false;
    final started = _startedAt;
    _startedAt = null;
    final path = await _recorder.stop() ?? _path;
    _path = null;
    if (path == null || path.isEmpty) return null;
    if (started != null && DateTime.now().difference(started) < _minDuration) {
      final file = File(path);
      if (await file.exists()) await file.delete();
      return null;
    }
    final file = File(path);
    if (!await file.exists()) return null;
    return PickedChatFile(
      path: path,
      displayName: 'voice.m4a',
      kind: ChatMediaKind.audio,
    );
  }

  @override
  Future<void> cancel() async {
    if (!_recording) return;
    _recording = false;
    _startedAt = null;
    final path = _path;
    _path = null;
    try {
      await _recorder.cancel();
    } catch (_) {
      try {
        await _recorder.stop();
      } catch (_) {}
    }
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
  }

  @override
  Future<void> dispose() async {
    await cancel();
    await _recorder.dispose();
  }
}
