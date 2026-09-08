import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/app.dart';
import 'package:ai_mom_baby/app_copy.dart';
import 'package:ai_mom_baby/data/fake_user_profile_repository.dart';
import 'package:ai_mom_baby/data/privacy_store.dart';
import 'package:ai_mom_baby/data/user_profile_repository.dart';
import 'package:ai_mom_baby/domain/stage.dart';
import 'package:ai_mom_baby/domain/user_profile_snapshot.dart';
import 'package:ai_mom_baby/providers.dart';

class _RouteRecorder extends NavigatorObserver {
  final names = <String?>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    names.add(route.settings.name);
  }
}

Future<void> _pumpApp(
  WidgetTester tester, {
  UserProfileRepository? repo,
  PrivacyStore? privacy,
  List<NavigatorObserver> observers = const [],
  List<String> exported = const [],
}) async {
  final fake = repo ?? FakeUserProfileRepository();
  final captured = List<String>.from(exported);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userProfileRepositoryProvider.overrideWithValue(fake),
        privacyStoreProvider.overrideWithValue(
          privacy ?? MemoryPrivacyStore(),
        ),
        dataExporterProvider.overrideWithValue((json) async {
          captured.add(json);
        }),
      ],
      child: AiMomBabyApp(
        navigatorObservers: observers,
        showLaunchNotice: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('AC-01-F01 home shows stage, week, four roles, task teaser',
      (tester) async {
    await _pumpApp(tester);
    expect(find.text('备孕'), findsOneWidget);
    expect(find.text('备孕中'), findsOneWidget);
    expect(find.text('小暖'), findsOneWidget);
    expect(find.text('林医生'), findsOneWidget);
    expect(find.text('苏心'), findsOneWidget);
    expect(find.text('阿嬷'), findsOneWidget);
    expect(find.text(AppCopy.todayTasksPlaceholder), findsOneWidget);
  });

  testWidgets('AC-01-F01 pregnant week copy', (tester) async {
    await _pumpApp(
      tester,
      repo: FakeUserProfileRepository(
        snapshot: const UserProfileSnapshot(
          stage: Stage.pregnant,
          weekValue: 16,
        ),
      ),
    );
    expect(find.text('孕期'), findsOneWidget);
    expect(find.text('孕16周'), findsOneWidget);
  });

  testWidgets('AC-01-F02 xiaonuan opens /chat?role=XIAONUAN', (tester) async {
    final observer = _RouteRecorder();
    await _pumpApp(tester, observers: [observer]);
    await tester.tap(find.byKey(const Key('role_XIAONUAN')));
    await tester.pumpAndSettle();
    expect(observer.names.last, '/chat?role=XIAONUAN');
    expect(find.text('小暖'), findsWidgets);
    expect(find.byKey(const Key('locked_banner')), findsNothing);
  });

  testWidgets('AC-01-F02 locked role shows banner and does not crash',
      (tester) async {
    final observer = _RouteRecorder();
    await _pumpApp(tester, observers: [observer]);
    await tester.tap(find.byKey(const Key('role_LIN')));
    await tester.pumpAndSettle();
    expect(observer.names.last, '/chat?role=LIN');
    expect(find.text(AppCopy.roleLockedBanner), findsOneWidget);
    expect(tester.widget<IconButton>(find.byKey(const Key('chat_send'))).onPressed,
        isNull);
  });

  testWidgets('AC-01-F03 exactly three tabs and empty conversation copy',
      (tester) async {
    await _pumpApp(tester);
    expect(find.byKey(const Key('nav_home')), findsOneWidget);
    expect(find.byKey(const Key('nav_chat')), findsOneWidget);
    expect(find.byKey(const Key('nav_me')), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('对话'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav_chat')));
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.emptyConversations), findsOneWidget);
  });

  testWidgets('AC-01-F04 home renders without throwing (no HTTP)',
      (tester) async {
    await _pumpApp(tester);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('home_week')), findsOneWidget);
  });

  testWidgets('AC-01-B01 getSnapshot called once; failure uses PREP fallback',
      (tester) async {
    final fake = FakeUserProfileRepository(throwOnGet: true);
    await _pumpApp(tester, repo: fake);
    expect(fake.getSnapshotCalls, 1);
    expect(find.text('备孕'), findsOneWidget);
    expect(find.text('备孕中'), findsOneWidget);
  });

  testWidgets('AC-01-F05 me page entries and clicks do not throw',
      (tester) async {
    final exported = <String>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(
            FakeUserProfileRepository(),
          ),
          privacyStoreProvider.overrideWithValue(MemoryPrivacyStore()),
          dataExporterProvider.overrideWithValue((json) async {
            exported.add(json);
          }),
        ],
        child: const AiMomBabyApp(showLaunchNotice: false),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav_me')));
    await tester.pumpAndSettle();

    expect(find.text('我的'), findsWidgets);
    expect(find.text(AppCopy.privacyTitle), findsOneWidget);
    expect(find.text(AppCopy.exportData), findsOneWidget);
    expect(find.text(AppCopy.deleteData), findsOneWidget);

    await tester.tap(find.byKey(const Key('me_privacy')));
    await tester.pumpAndSettle();
    expect(find.textContaining('健康数据以设备本地为主'), findsOneWidget);
    expect(find.textContaining('不上传整库'), findsOneWidget);
    await tester.tap(find.text(AppCopy.privacyClose));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('me_export')));
    await tester.pumpAndSettle();
    expect(exported, [AppCopy.emptyExportJson]);

    await tester.tap(find.byKey(const Key('me_delete')));
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.deleteConfirm), findsOneWidget);
    await tester.tap(find.text(AppCopy.privacyClose));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('cold start shows privacy notice then mock user week',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          privacyStoreProvider.overrideWithValue(MemoryPrivacyStore()),
          dataExporterProvider.overrideWithValue((_) async {}),
        ],
        child: const AiMomBabyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('launch_privacy_title')), findsOneWidget);
    expect(find.textContaining('健康数据以设备本地为主'), findsOneWidget);
    expect(find.textContaining('不上传整库'), findsOneWidget);
    await tester.tap(find.byKey(const Key('launch_privacy_dismiss')));
    await tester.pumpAndSettle();
    expect(find.text('孕期'), findsOneWidget);
    expect(find.text('孕16周'), findsOneWidget);
  });

  testWidgets('agree and continue leaves launch page for home', (tester) async {
    final privacy = MemoryPrivacyStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          privacyStoreProvider.overrideWithValue(privacy),
          userProfileRepositoryProvider.overrideWithValue(
            FakeUserProfileRepository(
              snapshot: const UserProfileSnapshot(
                stage: Stage.pregnant,
                weekValue: 16,
              ),
            ),
          ),
          dataExporterProvider.overrideWithValue((_) async {}),
        ],
        child: const AiMomBabyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('launch_privacy_agree')), findsOneWidget);
    await tester.tap(find.byKey(const Key('launch_privacy_agree')));
    await tester.pump();
    // FilledButton ink sparkle never settles; poll until home is built.
    for (var i = 0; i < 40; i++) {
      if (find.byKey(const Key('home_week')).evaluate().isNotEmpty) break;
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.byKey(const Key('launch_privacy_title')), findsNothing);
    expect(find.byKey(const Key('home_week')), findsOneWidget);
    expect(find.text('孕16周'), findsOneWidget);
    expect(await privacy.isAccepted(), isTrue);
  });
}
