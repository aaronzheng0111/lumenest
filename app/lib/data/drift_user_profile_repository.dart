import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../domain/stage.dart';
import '../domain/stage_resolver.dart';
import '../domain/user_profile_snapshot.dart';
import 'db/app_database.dart';
import 'db/database_provider.dart';
import 'db/domain_enums.dart';
import 'user_profile_repository.dart';

const kCheckBirthDateMessage = '请检查分娩日期';
const kSavedMessage = '已保存';

/// Drift-backed profile store (module 03). UI talks only to this interface.
class DriftUserProfileRepository implements UserProfileRepository {
  DriftUserProfileRepository(this._databaseProvider);

  final DatabaseProvider _databaseProvider;

  AppDatabase get _db => _databaseProvider.db;

  @override
  Future<UserProfileSnapshot> getSnapshot({DateTime? today}) async {
    final day = calendarDay(today ?? DateTime.now());
    await refresh(day);
    final user = await (_db.select(_db.users)..where((u) => u.id.equals(1)))
        .getSingle();
    final stage = StageX.fromWire(user.stage);
    return UserProfileSnapshot(
      stage: stage,
      weekValue: _weekValueFor(stage, user),
      weekUnit: _weekUnitFor(stage, user),
    );
  }

  /// AC-03-B02: recompute stage / week columns for [today]; no network.
  Future<void> refresh(DateTime today) async {
    final day = calendarDay(today);
    final user = await (_db.select(_db.users)..where((u) => u.id.equals(1)))
        .getSingleOrNull();
    if (user == null) return;

    final resolved = resolveStage(
      today: day,
      dueDate: user.dueDate,
      birthDate: user.birthDate,
      lastMenstruationDate: user.lastMenstruationDate,
    );

    final wire = _stageWire(resolved.stage);
    if (user.stage == wire &&
        user.pregnancyWeek == resolved.pregnancyWeek &&
        user.postpartumWeek == resolved.postpartumWeek) {
      return;
    }

    await (_db.update(_db.users)..where((u) => u.id.equals(1))).write(
      UsersCompanion(
        stage: Value(wire),
        pregnancyWeek: Value(resolved.pregnancyWeek),
        postpartumWeek: Value(resolved.postpartumWeek),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  @override
  Future<ProfileDraft> loadDraft() async {
    final user = await (_db.select(_db.users)..where((u) => u.id.equals(1)))
        .getSingle();
    return ProfileDraft(
      nickname: user.nickname,
      lastMenstruationDate: user.lastMenstruationDate,
      dueDate: user.dueDate,
      birthDate: user.birthDate,
    );
  }

  @override
  Future<void> saveEdits(ProfileEdits edits, {DateTime? today}) async {
    final day = calendarDay(today ?? DateTime.now());
    final existing = await (_db.select(_db.users)..where((u) => u.id.equals(1)))
        .getSingle();

    final nickname = edits.nickname ?? existing.nickname;
    if (nickname.isEmpty || nickname.length > 20) {
      throw ProfileValidationException('请检查昵称');
    }

    final dueDate = edits.clearDueDate
        ? null
        : (edits.dueDate ?? existing.dueDate);
    final birthDate = edits.clearBirthDate
        ? null
        : (edits.birthDate ?? existing.birthDate);
    final lmp = edits.clearLastMenstruationDate
        ? null
        : (edits.lastMenstruationDate ?? existing.lastMenstruationDate);

    _validateBirthDate(birthDate: birthDate, dueDate: dueDate, today: day);

    final resolved = resolveStage(
      today: day,
      dueDate: dueDate,
      birthDate: birthDate,
      lastMenstruationDate: lmp,
    );

    if (resolved.pregnancyWeek != null) {
      final rawCheck = pregnancyWeekFor(
        today: day,
        lastMenstruationDate: lmp,
        dueDate: dueDate!,
      );
      // clampPregnancyWeek already applied; log only when raw would exceed.
      final lmpDay = lmp != null
          ? calendarDay(lmp)
          : calendarDay(dueDate).subtract(const Duration(days: 280));
      final days = calendarDaysBetween(lmpDay, day);
      final unclamped = (days ~/ 7) + 1;
      if (unclamped < 1 || unclamped > 42) {
        debugPrint('pregnancyWeek clamped from $unclamped to $rawCheck');
      }
    }

    await (_db.update(_db.users)..where((u) => u.id.equals(1))).write(
      UsersCompanion(
        nickname: Value(nickname),
        lastMenstruationDate: Value(lmp),
        dueDate: Value(dueDate),
        birthDate: Value(birthDate),
        stage: Value(_stageWire(resolved.stage)),
        pregnancyWeek: Value(resolved.pregnancyWeek),
        postpartumWeek: Value(resolved.postpartumWeek),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  void _validateBirthDate({
    required DateTime? birthDate,
    required DateTime? dueDate,
    required DateTime today,
  }) {
    if (birthDate == null) return;
    final birth = calendarDay(birthDate);
    if (birth.isAfter(today)) {
      throw ProfileValidationException(kCheckBirthDateMessage);
    }
    if (dueDate != null) {
      final due = calendarDay(dueDate);
      if (calendarDaysBetween(birth, due) > 42) {
        // birth earlier than due by more than 42 days
        throw ProfileValidationException(kCheckBirthDateMessage);
      }
    }
  }

  static String _stageWire(Stage stage) => switch (stage) {
        Stage.prep => StageWire.prep,
        Stage.pregnant => StageWire.pregnant,
        Stage.delivery => StageWire.delivery,
        Stage.postpartum => StageWire.postpartum,
      };

  static int? _weekValueFor(Stage stage, User user) {
    return switch (stage) {
      Stage.prep => null,
      Stage.pregnant => user.pregnancyWeek,
      Stage.delivery => user.birthDate == null ? null : user.postpartumWeek,
      Stage.postpartum => user.postpartumWeek,
    };
  }

  static String? _weekUnitFor(Stage stage, User user) {
    return switch (stage) {
      Stage.prep => null,
      Stage.pregnant => 'PREGNANCY_WEEK',
      Stage.delivery => user.birthDate == null ? null : 'POSTPARTUM_WEEK',
      Stage.postpartum => 'POSTPARTUM_WEEK',
    };
  }
}
