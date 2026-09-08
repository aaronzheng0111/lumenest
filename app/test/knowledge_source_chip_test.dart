import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/data/conversation_repository.dart';
import 'package:ai_mom_baby/features/chat/chat_bubble.dart';
import 'package:ai_mom_baby/theme/app_theme.dart';

void main() {
  testWidgets('AC-07-F01 shows 来源： and up to 3 titles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: ChatBubble(
            message: ChatMessage(
              id: 1,
              conversationId: 1,
              role: 'assistant',
              content: '少量多餐会舒服些。',
              createdAt: DateTime.utc(2026, 1, 1),
              speakerRole: 'XIAONUAN',
              sourceTitles: const [
                '孕吐饮食建议（假数据）',
                '孕期食物红黑榜（假数据）',
                '孕检时间表概览（假数据）',
                '多余来源不应展示',
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('来源：'), findsOneWidget);
    expect(find.byKey(const Key('source_chip_孕吐饮食建议（假数据）')), findsOneWidget);
    expect(find.byKey(const Key('source_chip_多余来源不应展示')), findsNothing);
  });

  testWidgets('AC-07-F01 no 来源 when empty hits', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: ChatBubble(
            message: ChatMessage(
              id: 2,
              conversationId: 1,
              role: 'assistant',
              content: '先歇一歇。',
              createdAt: DateTime.utc(2026, 1, 1),
              speakerRole: 'XIAONUAN',
            ),
          ),
        ),
      ),
    );
    expect(find.text('来源：'), findsNothing);
  });
}
