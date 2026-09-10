import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/chat/chat_media.dart';
import 'package:ai_mom_baby/chat/chat_outgoing.dart';
import 'package:ai_mom_baby/data/local_chat_media_store.dart';

void main() {
  group('ChatMediaItem', () {
    test('should round-trip encode and decode list in mediaRef', () {
      const items = [
        ChatMediaItem(
          id: 'a1',
          kind: ChatMediaKind.image,
          localPath: '/tmp/a.jpg',
          displayName: 'a.jpg',
          sizeBytes: 1200,
        ),
        ChatMediaItem(
          id: 'b2',
          kind: ChatMediaKind.audio,
          localPath: '/tmp/b.m4a',
          displayName: 'voice.m4a',
          sizeBytes: 8000,
        ),
      ];
      final encoded = ChatMediaItem.encodeList(items);
      expect(encoded, isNotEmpty);
      final decoded = ChatMediaItem.decodeList(encoded);
      expect(decoded, hasLength(2));
      expect(decoded[0].id, 'a1');
      expect(decoded[0].kind, ChatMediaKind.image);
      expect(decoded[1].kind, ChatMediaKind.audio);
      expect(decoded[1].displayName, 'voice.m4a');
    });

    test('should return empty list for null or blank mediaRef', () {
      expect(ChatMediaItem.decodeList(null), isEmpty);
      expect(ChatMediaItem.decodeList(''), isEmpty);
      expect(ChatMediaItem.decodeList('   '), isEmpty);
    });
  });

  group('ChatOutgoing', () {
    test('should use trimmed text when present', () {
      final payload = ChatOutgoing.build(
        text: '  你好  ',
        media: const [
          ChatMediaItem(
            id: '1',
            kind: ChatMediaKind.file,
            localPath: '/x.pdf',
            displayName: 'x.pdf',
          ),
        ],
      );
      expect(payload.content, '你好');
      expect(payload.mediaRef, isNotNull);
      expect(payload.isEmpty, isFalse);
    });

    test('should use voice placeholder when only audio', () {
      final payload = ChatOutgoing.build(
        text: '   ',
        media: const [
          ChatMediaItem(
            id: '1',
            kind: ChatMediaKind.audio,
            localPath: '/v.m4a',
            displayName: 'voice.m4a',
          ),
        ],
      );
      expect(payload.content, ChatOutgoing.voicePlaceholder);
      expect(payload.mediaRef, isNotNull);
    });

    test('should use file placeholder when only non-audio media', () {
      final payload = ChatOutgoing.build(
        text: '',
        media: const [
          ChatMediaItem(
            id: '1',
            kind: ChatMediaKind.file,
            localPath: '/r.pdf',
            displayName: 'report.pdf',
          ),
        ],
      );
      expect(payload.content, contains('report.pdf'));
      expect(payload.content, startsWith(ChatOutgoing.filePlaceholderPrefix));
    });

    test('should be empty when no text and no media', () {
      final payload = ChatOutgoing.build(text: '  ', media: const []);
      expect(payload.isEmpty, isTrue);
      expect(payload.mediaRef, isNull);
    });
  });

  group('ChatMediaLimits', () {
    test('should reject oversize file', () {
      expect(
        ChatMediaLimits.validateSize(ChatMediaLimits.maxBytes + 1),
        ChatMediaValidation.tooLarge,
      );
      expect(
        ChatMediaLimits.validateSize(ChatMediaLimits.maxBytes),
        ChatMediaValidation.ok,
      );
    });

    test('should reject too many pending attachments', () {
      expect(
        ChatMediaLimits.canAddMore(ChatMediaLimits.maxAttachments),
        isFalse,
      );
      expect(
        ChatMediaLimits.canAddMore(ChatMediaLimits.maxAttachments - 1),
        isTrue,
      );
    });
  });

  group('LocalChatMediaStore', () {
    late Directory root;
    late LocalChatMediaStore store;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('chat_media_');
      store = LocalChatMediaStore(rootDirectory: () async => root);
    });

    tearDown(() async {
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });

    test('should copy source file into store and return ChatMediaItem',
        () async {
      final source = File('${root.path}/src.txt');
      await source.writeAsString('hello media');
      final item = await store.importFile(
        sourcePath: source.path,
        displayName: 'note.txt',
        kind: ChatMediaKind.file,
      );
      expect(item.kind, ChatMediaKind.file);
      expect(item.displayName, 'note.txt');
      expect(File(item.localPath).existsSync(), isTrue);
      expect(await File(item.localPath).readAsString(), 'hello media');
      expect(item.sizeBytes, greaterThan(0));
    });

    test('should throw ChatMediaTooLargeException when over limit', () async {
      final source = File('${root.path}/big.bin');
      await source.writeAsBytes(
        List<int>.filled(ChatMediaLimits.maxBytes + 1, 1),
      );
      expect(
        () => store.importFile(
          sourcePath: source.path,
          displayName: 'big.bin',
          kind: ChatMediaKind.file,
        ),
        throwsA(isA<ChatMediaTooLargeException>()),
      );
    });
  });
}
