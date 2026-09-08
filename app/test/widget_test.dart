import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/main.dart';

void main() {
  testWidgets('Glass token preview shows brand and tabs', (tester) async {
    await tester.pumpWidget(const AiMomBabyApp());
    await tester.pumpAndSettle();

    expect(find.text('孕育小家'), findsWidgets);
    expect(find.text('孕16周'), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('对话'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
  });
}
