import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/agent/tool_acl.dart';
import 'package:ai_mom_baby/agent/tool_labels.dart';
import 'package:ai_mom_baby/app_copy.dart';
import 'package:ai_mom_baby/chat/chat_suggestions_catalog.dart';
import 'package:ai_mom_baby/domain/agent_role.dart';
import 'package:ai_mom_baby/features/chat/chat_composer.dart';
import 'package:ai_mom_baby/features/chat/chat_mention_query.dart';
import 'package:ai_mom_baby/features/chat/chat_pending_tools.dart';
import 'package:ai_mom_baby/features/chat/chat_tool_status.dart';
import 'package:ai_mom_baby/providers.dart';

void main() {
  group('findActiveMention', () {
    test('detects trailing @ with empty query', () {
      final q = findActiveMention('hello @', 7);
      expect(q?.atIndex, 6);
      expect(q?.query, '');
    });

    test('detects prefix filter fragment', () {
      final q = findActiveMention('@林', 2);
      expect(q?.atIndex, 0);
      expect(q?.query, '林');
    });

    test('ignores completed mention after space', () {
      expect(findActiveMention('@林医生 你好', 8), isNull);
    });

    test('ignores email-like @ without leading space', () {
      expect(findActiveMention('a@b', 3), isNull);
    });
  });

  group('filterMentionRoles', () {
    test('filters by displayName prefix', () {
      final roles = filterMentionRoles(
        AgentRole.values,
        '林',
        (r) => r.displayName,
      );
      expect(roles, [AgentRole.lin]);
    });
  });

  group('predictPendingTools', () {
    test('predicts getCurrentTime for time questions', () {
      expect(
        predictPendingTools(
          userText: '现在时间是？',
          speaker: AgentRole.xiaonuan,
        ),
        [AgentTool.getCurrentTime],
      );
    });

    test('empty for unrelated text', () {
      expect(
        predictPendingTools(
          userText: '你好',
          speaker: AgentRole.xiaonuan,
        ),
        isEmpty,
      );
    });
  });

  group('ChatSuggestionsCatalog', () {
    test('parses scenes and prefers role override', () {
      const raw = '''
{
  "scenes": {
    "solo": ["你好，介绍一下你自己！", "现在时间是？"],
    "group": ["群聊推荐"],
    "XIAONUAN": ["小暖专属"]
  }
}
''';
      final catalog = parseChatSuggestionsCatalog(raw);
      expect(
        catalog.suggestionsFor(ChatSuggestionScene.solo),
        ['你好，介绍一下你自己！', '现在时间是？'],
      );
      expect(
        catalog.suggestionsFor(
          ChatSuggestionScene.solo,
          role: AgentRole.xiaonuan,
        ),
        ['小暖专属'],
      );
      expect(
        catalog.suggestionsFor(ChatSuggestionScene.group),
        ['群聊推荐'],
      );
    });
  });

  group('chatSuggestionsForProvider', () {
    test('resolves scene prompts via Riverpod', () async {
      const raw = '''
{
  "scenes": {
    "solo": ["A", "B"],
    "group": ["G"]
  }
}
''';
      final container = ProviderContainer(
        overrides: [
          chatSuggestionsCatalogProvider.overrideWith(
            (ref) async => parseChatSuggestionsCatalog(raw),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(chatSuggestionsCatalogProvider.future);
      expect(
        container.read(
          chatSuggestionsForProvider((
            scene: ChatSuggestionScene.solo,
            role: null,
          )),
        ),
        ['A', 'B'],
      );
      expect(
        container.read(
          chatSuggestionsForProvider((
            scene: ChatSuggestionScene.group,
            role: null,
          )),
        ),
        ['G'],
      );
    });
  });

  testWidgets('composer shows mention picker and inserts role', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatComposer(
            controller: controller,
            enabled: true,
            hintText: 'hint',
            onSend: () {},
            enableMentions: true,
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('chat_input')), '@');
    await tester.pump();
    expect(find.byKey(const Key('chat_mention_picker')), findsOneWidget);
    expect(find.byKey(const Key('chat_mention_LIN')), findsOneWidget);

    await tester.tap(find.byKey(const Key('chat_mention_LIN')));
    await tester.pump();
    expect(controller.text, '@林医生 ');
    expect(find.byKey(const Key('chat_mention_picker')), findsNothing);
  });

  testWidgets('composer shows suggested prompts when enabled', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? picked;
    const prompts = ['你好，介绍一下你自己！', '现在时间是？'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatComposer(
            controller: controller,
            enabled: true,
            hintText: 'hint',
            onSend: () {},
            showSuggestions: true,
            suggestedPrompts: prompts,
            onSuggestionSelected: (v) => picked = v,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('chat_suggested_prompts')), findsOneWidget);
    expect(find.text(prompts.first), findsOneWidget);
    await tester.tap(find.byKey(const Key('chat_suggestion_0')));
    await tester.pump();
    expect(picked, prompts.first);
  });

  testWidgets('awaiting reply shows tool chip', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChatAwaitingReply(
            tools: [AgentTool.getCurrentTime],
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('chat_tool_getCurrentTime')), findsOneWidget);
    expect(
      find.text(
        AppCopy.callingTool(AgentToolLabels.displayName(AgentTool.getCurrentTime)),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('chat_loading')), findsOneWidget);
  });
}
