import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/data/fake_user_profile_repository.dart';
import 'package:ai_mom_baby/domain/stage.dart';
import 'package:ai_mom_baby/domain/user_profile_snapshot.dart';
import 'package:ai_mom_baby/features/home/home_page.dart';
import 'package:ai_mom_baby/providers.dart';

void main() {
  testWidgets('home journey hero collapses into pinned bar while scrolling',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(
            FakeUserProfileRepository(
              snapshot: const UserProfileSnapshot(
                stage: Stage.pregnant,
                weekValue: 16,
              ),
            ),
          ),
          todayTaskCardsProvider.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.transparent,
            body: HomePage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_week')), findsOneWidget);
    expect(find.text('孕16周'), findsWidgets);

    await tester.drag(
      find.byKey(const Key('home_scroll')),
      const Offset(0, -360),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('journey_pinned_bar')), findsOneWidget);
    expect(find.text('孕16周'), findsWidgets);
  });
}
