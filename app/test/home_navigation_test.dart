import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/app.dart';
import 'package:ai_mom_baby/app_copy.dart';
import 'package:ai_mom_baby/data/fake_user_profile_repository.dart';
import 'package:ai_mom_baby/data/fixture_store.dart';
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
  List<Override> extraOverrides = const [],
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
        todayTaskCardsProvider.overrideWith((ref) async => const []),
        ...extraOverrides,
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
  testWidgets('AC-01-F01 home shows stage, week, four roles, care module',
      (tester) async {
    await _pumpApp(tester);
    expect(find.text('备孕'), findsOneWidget);
    expect(find.text('备孕中'), findsOneWidget);
    expect(find.text('小暖'), findsOneWidget);
    expect(find.text('林医生'), findsOneWidget);
    expect(find.text('苏心'), findsOneWidget);
    expect(find.text('阿嬷'), findsOneWidget);
    expect(find.text('今日照护'), findsOneWidget);
    expect(find.text(AppCopy.noTasksToday), findsOneWidget);
    expect(find.byKey(const Key('hydration_module')), findsOneWidget);
    expect(find.byKey(const Key('health_snapshot_strip')), findsOneWidget);
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
    await tester.scrollUntilVisible(
      find.byKey(const Key('role_XIAONUAN')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('role_XIAONUAN')));
    await tester.pumpAndSettle();
    expect(observer.names.last, '/chat?role=XIAONUAN');
    expect(find.text('小暖'), findsWidgets);
    expect(find.byKey(const Key('locked_banner')), findsNothing);
  });

  testWidgets('AC-01-F02 / AC-11-F01 unlocked role opens chat without banner',
      (tester) async {
    final observer = _RouteRecorder();
    await _pumpApp(tester, observers: [observer]);
    await tester.scrollUntilVisible(
      find.byKey(const Key('role_LIN')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('role_LIN')));
    await tester.pumpAndSettle();
    expect(observer.names.last, '/chat?role=LIN');
    expect(find.byKey(const Key('locked_banner')), findsNothing);
    expect(
      tester.widget<IconButton>(find.byKey(const Key('chat_send'))).onPressed,
      isNotNull,
    );
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
          todayTaskCardsProvider.overrideWith((ref) async => const []),
        ],
        child: const AiMomBabyApp(showLaunchNotice: false),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav_me')));
    await tester.pumpAndSettle();

    expect(find.text('我的'), findsWidgets);
    await tester.scrollUntilVisible(
      find.byKey(const Key('me_privacy')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
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

  testWidgets('AC-16-F01 chat send blocked until privacy accepted',
      (tester) async {
    await _pumpApp(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('role_XIAONUAN')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('role_XIAONUAN')));
    await tester.pumpAndSettle();
    // Bootstrap may snack when DB isn't ready in widget tests; clear so send is hittable.
    final messenger = ScaffoldMessenger.of(
      tester.element(find.byKey(const Key('chat_send'))),
    );
    messenger.hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat_send')));
    await tester.pump();
    expect(find.text(AppCopy.privacyRequiredToChat), findsOneWidget);
  });

  testWidgets('AC-16-F01 me privacy sheet agree persists', (tester) async {
    final privacy = MemoryPrivacyStore();
    await _pumpApp(tester, privacy: privacy);
    await tester.tap(find.byKey(const Key('nav_me')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('me_privacy')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('me_privacy')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('privacy_sheet_title')), findsOneWidget);
    expect(find.text(AppCopy.privacyTitle), findsWidgets);
    await tester.tap(find.byKey(const Key('privacy_sheet_agree')));
    await tester.pump();
    for (var i = 0; i < 20; i++) {
      if (find.byKey(const Key('privacy_sheet_title')).evaluate().isEmpty) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.byKey(const Key('privacy_sheet_title')), findsNothing);
    expect(await privacy.isAccepted(), isTrue);
  });

  testWidgets('AC-16-F02 export JSON has no secrets', (tester) async {
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
          todayTaskCardsProvider.overrideWith((ref) async => const []),
        ],
        child: const AiMomBabyApp(showLaunchNotice: false),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav_me')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('me_export')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('me_export')));
    await tester.pumpAndSettle();
    expect(exported, [AppCopy.emptyExportJson]);
    expect(exported.single.contains('sk-'), isFalse);
  });

  testWidgets('AC-16-F03 delete clears privacyAccepted', (tester) async {
    final privacy = MemoryPrivacyStore(accepted: true);
    await _pumpApp(tester, privacy: privacy);
    await tester.tap(find.byKey(const Key('nav_me')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('me_delete')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('me_delete')));
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.deleteConfirm), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, AppCopy.deleteData));
    await tester.pumpAndSettle();
    expect(await privacy.isAccepted(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cold start shows privacy notice then mock user week',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(
            AssetMockUserProfileRepository(),
          ),
          privacyStoreProvider.overrideWithValue(MemoryPrivacyStore()),
          dataExporterProvider.overrideWithValue((_) async {}),
          todayTaskCardsProvider.overrideWith((ref) async => const []),
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
          todayTaskCardsProvider.overrideWith((ref) async => const []),
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

  testWidgets('AC-11-F02 group consult button opens /chat/group',
      (tester) async {
    final observer = _RouteRecorder();
    await _pumpApp(tester, observers: [observer]);
    await tester.tap(find.byKey(const Key('nav_chat')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('group_consult_btn')), findsOneWidget);
    await tester.tap(find.byKey(const Key('group_consult_btn')));
    await tester.pumpAndSettle();
    expect(observer.names.last, '/chat/group');
    expect(find.text(AppCopy.groupConsult), findsWidgets);
  });

  testWidgets('AC-11-F02 group consult disabled shows upgrade copy',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(
            FakeUserProfileRepository(),
          ),
          privacyStoreProvider.overrideWithValue(MemoryPrivacyStore()),
          groupConsultEnabledProvider.overrideWithValue(false),
          todayTaskCardsProvider.overrideWith((ref) async => const []),
        ],
        child: const AiMomBabyApp(showLaunchNotice: false),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav_chat')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('group_consult_btn')));
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.groupConsultNeedsUpgrade), findsOneWidget);
  });

  testWidgets('profile sections are reachable from Me tab', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byKey(const Key('nav_me')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile_hero_name')), findsOneWidget);
    expect(find.byKey(const Key('profile_section_personal')), findsOneWidget);
    expect(find.byKey(const Key('profile_section_health')), findsOneWidget);
    await tester.tap(find.byKey(const Key('profile_section_personal')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('personal_nickname')), findsOneWidget);
    expect(find.byKey(const Key('profile_section_save')), findsOneWidget);
  });
}
