import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/app_copy.dart';
import 'package:ai_mom_baby/data/active_user_store.dart';
import 'package:ai_mom_baby/data/db/database_provider.dart';
import 'package:ai_mom_baby/data/drift_user_profile_repository.dart';
import 'package:ai_mom_baby/data/user_profile_repository.dart';
import 'package:ai_mom_baby/domain/stage.dart';

void main() {
  late DriftDatabaseProvider dbProvider;
  late DriftUserProfileRepository repo;

  setUp(() async {
    dbProvider = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await dbProvider.init();
    repo = DriftUserProfileRepository(dbProvider, activeUserStore: MemoryActiveUserStore());
  });

  tearDown(() async {
    await dbProvider.close();
  });

  test('AC-03-B02 refresh advances pregnancy week when day +1', () async {
    final today = DateTime(2026, 9, 7);
    await repo.saveEdits(
      ProfileEdits(
        dueDate: DateTime(2026, 12, 16),
        lastMenstruationDate: DateTime(2026, 3, 12),
      ),
      today: today,
    );
    final before = await repo.getSnapshot(today: today);
    expect(before.stage, Stage.pregnant);
    expect(before.weekValue, 26);

    final nextDay = DateTime(2026, 9, 14); // +7 days → week 27
    await repo.refresh(nextDay);
    final after = await repo.getSnapshot(today: nextDay);
    expect(after.weekValue, 27);
  });

  test('AC-03-F03 invalid birth date rejected and DB unchanged', () async {
    final today = DateTime(2026, 9, 7);
    await repo.saveEdits(
      const ProfileEdits(nickname: '验收甲', dueDate: null),
      today: today,
    );
    final draftBefore = await repo.loadDraft();
    expect(draftBefore.nickname, '验收甲');
    expect(draftBefore.birthDate, isNull);

    expect(
      () => repo.saveEdits(
        ProfileEdits(
          dueDate: DateTime(2026, 12, 16),
          // Birth 50 days before due (>42)
          birthDate: DateTime(2026, 10, 27),
        ),
        today: today,
      ),
      throwsA(
        isA<ProfileValidationException>().having(
          (e) => e.message,
          'message',
          AppCopy.checkBirthDate,
        ),
      ),
    );

    final draftAfter = await repo.loadDraft();
    expect(draftAfter.nickname, '验收甲');
    expect(draftAfter.birthDate, isNull);
    expect(draftAfter.dueDate, isNull);
  });

  test('saveEdits future birth date rejected', () async {
    final today = DateTime(2026, 9, 7);
    expect(
      () => repo.saveEdits(
        ProfileEdits(
          dueDate: DateTime(2026, 8, 1),
          birthDate: DateTime(2026, 9, 8),
        ),
        today: today,
      ),
      throwsA(isA<ProfileValidationException>()),
    );
  });
}
