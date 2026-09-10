import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/chat/chat_timestamp_format.dart';
import 'package:ai_mom_baby/data/conversation_repository.dart';
import 'package:ai_mom_baby/domain/agent_role.dart';
import 'package:ai_mom_baby/features/chat/chat_bubble.dart';
import 'package:ai_mom_baby/features/conversations/conversation_list_page.dart';
import 'package:ai_mom_baby/providers.dart';

void main() {
  group('formatConversationTimestamp', () {
    final now = DateTime(2026, 9, 10, 18, 30);

    test('uses time for today', () {
      expect(
        formatConversationTimestamp(
          DateTime(2026, 9, 10, 9, 5),
          now: now,
        ),
        '09:05',
      );
    });

    test('uses yesterday for the previous day', () {
      expect(
        formatConversationTimestamp(
          DateTime(2026, 9, 9, 23, 59),
          now: now,
        ),
        '昨天',
      );
    });

    test('uses month and day within the current year', () {
      expect(
        formatConversationTimestamp(
          DateTime(2026, 8, 2),
          now: now,
        ),
        '8/2',
      );
    });

    test('includes the year for older conversations', () {
      expect(
        formatConversationTimestamp(
          DateTime(2025, 12, 31),
          now: now,
        ),
        '2025/12/31',
      );
    });
  });

  group('formatChatBubbleTimestamp', () {
    final now = DateTime(2026, 9, 10, 18, 30);

    test('uses time for today', () {
      expect(
        formatChatBubbleTimestamp(
          DateTime(2026, 9, 10, 9, 5),
          now: now,
        ),
        '09:05',
      );
    });

    test('prefixes yesterday with a label', () {
      expect(
        formatChatBubbleTimestamp(
          DateTime(2026, 9, 9, 23, 59),
          now: now,
        ),
        '昨天 23:59',
      );
    });

    test('uses month, day, and time within the current year', () {
      expect(
        formatChatBubbleTimestamp(
          DateTime(2026, 8, 2, 8, 7),
          now: now,
        ),
        '8月2日 08:07',
      );
    });

    test('includes the year for older messages', () {
      expect(
        formatChatBubbleTimestamp(
          DateTime(2025, 12, 31, 22, 1),
          now: now,
        ),
        '2025/12/31 22:01',
      );
    });
  });

  testWidgets('chat bubble renders its timestamp inside the bubble', (
    tester,
  ) async {
    final createdAt = DateTime.now().subtract(const Duration(minutes: 5));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatBubble(
            message: ChatMessage(
              id: 7,
              conversationId: 1,
              role: 'assistant',
              content: '你好',
              createdAt: createdAt,
              speakerRole: AgentRole.xiaonuan.wireId,
            ),
            showActions: false,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('bubble_timestamp_7')), findsOneWidget);
    expect(find.text(formatChatBubbleTimestamp(createdAt)), findsOneWidget);
  });

  testWidgets('conversation history renders a compact timestamp', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationListProvider.overrideWith(
            (ref) async => [
              ConversationListItem(
                id: 9,
                role: AgentRole.lin,
                lastMessageAt: DateTime.now(),
                preview: '今天感觉怎么样？',
              ),
            ],
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ConversationListPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('conversation_timestamp_9')), findsOneWidget);
  });
}
