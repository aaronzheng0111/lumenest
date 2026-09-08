import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/app.dart';
import 'package:ai_mom_baby/data/fake_user_profile_repository.dart';
import 'package:ai_mom_baby/data/privacy_store.dart';
import 'package:ai_mom_baby/providers.dart';

void main() {
  testWidgets('app boots into home shell', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(
            FakeUserProfileRepository(),
          ),
          privacyStoreProvider.overrideWithValue(MemoryPrivacyStore()),
          dataExporterProvider.overrideWithValue((_) async {}),
          todayTaskCardsProvider.overrideWith((ref) async => const []),
        ],
        child: const AiMomBabyApp(showLaunchNotice: false),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('小暖'), findsOneWidget);
  });
}
