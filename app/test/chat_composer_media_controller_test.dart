import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/chat/chat_media.dart';
import 'package:ai_mom_baby/chat/chat_outgoing.dart';
import 'package:ai_mom_baby/data/chat_attachment_picker.dart';
import 'package:ai_mom_baby/data/chat_composer_media_controller.dart';
import 'package:ai_mom_baby/data/chat_voice_recorder.dart';
import 'package:ai_mom_baby/data/local_chat_media_store.dart';

class _FakePicker implements ChatAttachmentPicker {
  _FakePicker(this.files);
  List<PickedChatFile> files;

  @override
  Future<List<PickedChatFile>> pickAttachments() async => files;
}

class _FakeRecorder implements ChatVoiceRecorder {
  _FakeRecorder({this.file, this.throwPermission = false});

  PickedChatFile? file;
  bool throwPermission;
  bool recording = false;

  @override
  bool get isRecording => recording;

  @override
  Future<void> start() async {
    if (throwPermission) throw const ChatVoicePermissionException();
    recording = true;
  }

  @override
  Future<PickedChatFile?> stop() async {
    recording = false;
    return file;
  }

  @override
  Future<void> cancel() async {
    recording = false;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  late Directory root;
  late LocalChatMediaStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('composer_media_');
    store = LocalChatMediaStore(
      rootDirectory: () async => root,
      idFactory: () => 'fixed-id',
    );
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  group('ChatComposerMediaController', () {
    test('should import picked files into pending', () async {
      final source = File('${root.path}/doc.pdf');
      await source.writeAsString('pdf');
      final controller = ChatComposerMediaController(
        picker: _FakePicker([
          PickedChatFile(
            path: source.path,
            displayName: 'doc.pdf',
            kind: ChatMediaKind.file,
          ),
        ]),
        recorder: _FakeRecorder(),
        store: store,
      );
      addTearDown(controller.dispose);

      final result = await controller.attachFiles();
      expect(result, ChatMediaAttachResult.ok);
      expect(controller.pending, hasLength(1));
      expect(controller.pending.single.displayName, 'doc.pdf');
      expect(controller.canSend(''), isTrue);
    });

    test('should auto-ready voice clip for send', () async {
      final source = File('${root.path}/voice.m4a');
      await source.writeAsBytes(List<int>.filled(200, 1));
      final controller = ChatComposerMediaController(
        picker: _FakePicker(const []),
        recorder: _FakeRecorder(
          file: PickedChatFile(
            path: source.path,
            displayName: 'voice.m4a',
            kind: ChatMediaKind.audio,
          ),
        ),
        store: store,
      );
      addTearDown(controller.dispose);

      expect(await controller.toggleVoice(), ChatVoiceToggleResult.started);
      expect(controller.isRecording, isTrue);
      expect(
        await controller.toggleVoice(),
        ChatVoiceToggleResult.readyToSend,
      );
      expect(controller.pending.single.kind, ChatMediaKind.audio);

      final payload = controller.takeOutgoing('');
      expect(payload.content, ChatOutgoing.voicePlaceholder);
      expect(payload.mediaRef, isNotNull);
      expect(controller.pending, isEmpty);
    });

    test('should surface permission denial', () async {
      final controller = ChatComposerMediaController(
        picker: _FakePicker(const []),
        recorder: _FakeRecorder(throwPermission: true),
        store: store,
      );
      addTearDown(controller.dispose);

      expect(
        await controller.toggleVoice(),
        ChatVoiceToggleResult.permissionDenied,
      );
    });
  });
}
