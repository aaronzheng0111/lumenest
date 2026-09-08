import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/main.dart';
import 'package:ai_mom_baby/theme/spacing_tokens.dart';
import 'package:ai_mom_baby/widgets/glass/glass_app_bar.dart';
import 'package:ai_mom_baby/widgets/glass/glass_tab_bar.dart';

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

  testWidgets('preview list clears glass app bar and tab bar', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 47, bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(top: 47, bottom: 48);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(const AiMomBabyApp());
    await tester.pumpAndSettle();

    final appBar = tester.getRect(find.byType(GlassAppBar));
    final hero = tester.getRect(find.text('孕16周'));
    final tabBar = tester.getRect(find.byType(GlassTabBar));
    final listView = tester.widget<ListView>(find.byType(ListView));
    final listRect = tester.getRect(find.byType(ListView));
    final listPadding = listView.padding! as EdgeInsets;
    final contentBottom = listRect.bottom - listPadding.bottom;

    expect(
      hero.top,
      greaterThanOrEqualTo(appBar.bottom),
      reason: 'hero card must sit below the glass app bar',
    );
    expect(
      contentBottom,
      lessThanOrEqualTo(tabBar.top - SpacingTokens.lg),
      reason: 'scrolled content must clear the floating tab bar by 16px',
    );
  });
}
