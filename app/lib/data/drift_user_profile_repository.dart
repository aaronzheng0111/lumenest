import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../domain/rich_user_profile.dart';
import '../domain/stage.dart';
import '../domain/stage_resolver.dart';
import '../domain/user_profile_snapshot.dart';
import 'active_user_store.dart';
import 'db/app_database.dart';
import 'db/database_provider.dart';
import 'db/domain_enums.dart';
import 'user_profile_repository.dart';

const kCheckBirthDateMessage = '请检查分娩日期';
const kSavedMessage = '已保存';

/// Drift-backed profile store (module 03 + rich multi-user profile).
///
/// Manual Profile UI and agent tools both call this repository so edits stay
/// in sync on the same `users` row / `profile_json` blob.
class DriftUserProfileRepository implements UserProfileRepository {
  DriftUserProfileRepository(
    this._databaseProvider, {
    required ActiveUserStore activeUserStore,
  }) : _activeUserStore = activeUserStore;

  final DatabaseProvider _databaseProvider;
  final ActiveUserStore _activeUserStore;

  AppDatabase get _db => _databaseProvider.db;

  @override
  Future<int> getActiveUserId() => _activeUserStore.getActiveUserId();

  Future<int> _resolveUserId() async {
    final id = await _activeUserStore.getActiveUserId();
    final row =
        await (_db.select(_db.users)..where((u) => u.id.equals(id)))
            .getSingleOrNull();
    if (row != null) return id;
    // Fallback to seed user if prefs point at a deleted account.
    await _activeUserStore.setActiveUserId(1);
    return 1;
  }

  @override
  Future<List<LocalAccount>> listAccounts() async {
    final active = await _resolveUserId();
    final rows = await _db.select(_db.users).get();
    rows.sort((a, b) => a.id.compareTo(b.id));
    return [
      for (final u in rows)
        LocalAccount(
          id: u.id,
          nickname: u.nickname,
          isActive: u.id == active,
        ),
    ];
  }

  @override
  Future<int> createAccount({
    String nickname = '妈妈',
    bool switchTo = true,
  }) async {
    final trimmed = nickname.trim().isEmpty ? '妈妈' : nickname.trim();
    if (trimmed.length > 20) {
      throw ProfileValidationException('请检查昵称');
    }
    final maxId = await _db
        .customSelect('SELECT MAX(id) AS m FROM users')
        .getSingle();
    final nextId = (maxId.read<int?>('m') ?? 0) + 1;
    final now = DateTime.now().toUtc();
    await _db.into(_db.users).insert(
          UsersCompanion.insert(
            id: Value(nextId),
            nickname: Value(trimmed),
            stage: const Value(StageWire.prep),
            profileJson: const Value('{}'),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await _db.into(_db.subscriptions).insert(
          SubscriptionsCompanion.insert(
            userId: nextId,
            plan: PlanWire.free,
            startAt: now,
            dailyChatQuota: 1,
            monthlyReportQuota: 0,
            groupConsultEnabled: const Value(false),
          ),
        );
    if (switchTo) {
      await _activeUserStore.setActiveUserId(nextId);
    }
    return nextId;
  }

  @override
  Future<void> switchAccount(int userId) async {
    final row = await (_db.select(_db.users)..where((u) => u.id.equals(userId)))
        .getSingleOrNull();
    if (row == null) {
      throw ProfileValidationException('账号不存在');
    }
    await _activeUserStore.setActiveUserId(userId);
  }

  @override
  Future<UserProfileSnapshot> getSnapshot({DateTime? today}) async {
    final day = calendarDay(today ?? DateTime.now());
    final userId = await _resolveUserId();
    await refresh(day, userId: userId);
    final user = await (_db.select(_db.users)..where((u) => u.id.equals(userId)))
        .getSingle();
    final stage = StageX.fromWire(user.stage);
    return UserProfileSnapshot(
      stage: stage,
      weekValue: _weekValueFor(stage, user),
      weekUnit: _weekUnitFor(stage, user),
      userId: userId,
      nickname: user.nickname,
      rich: RichUserProfile.decode(user.profileJson),
      lastMenstruationDate: user.lastMenstruationDate,
      dueDate: user.dueDate,
      birthDate: user.birthDate,
    );
  }

  /// AC-03-B02: recompute stage / week columns for [today]; no network.
  Future<void> refresh(DateTime today, {int? userId}) async {
    final day = calendarDay(today);
    final id = userId ?? await _resolveUserId();
    final user = await (_db.select(_db.users)..where((u) => u.id.equals(id)))
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

    await (_db.update(_db.users)..where((u) => u.id.equals(id))).write(
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
    final userId = await _resolveUserId();
    final user = await (_db.select(_db.users)..where((u) => u.id.equals(userId)))
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
    final userId = await _resolveUserId();
    final existing =
        await (_db.select(_db.users)..where((u) => u.id.equals(userId)))
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
      final lmpDay = lmp != null
          ? calendarDay(lmp)
          : calendarDay(dueDate).subtract(const Duration(days: 280));
      final days = calendarDaysBetween(lmpDay, day);
      final unclamped = (days ~/ 7) + 1;
      if (unclamped < 1 || unclamped > 42) {
        debugPrint('pregnancyWeek clamped from $unclamped to $rawCheck');
      }
    }

    await (_db.update(_db.users)..where((u) => u.id.equals(userId))).write(
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

  @override
  Future<RichUserProfile> loadRichProfile() async {
    final userId = await _resolveUserId();
    final user = await (_db.select(_db.users)..where((u) => u.id.equals(userId)))
        .getSingle();
    return RichUserProfile.decode(user.profileJson);
  }

  @override
  Future<void> saveRichProfile(RichUserProfile profile) async {
    final userId = await _resolveUserId();
    await (_db.update(_db.users)..where((u) => u.id.equals(userId))).write(
      UsersCompanion(
        profileJson: Value(profile.encode()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  @override
  Future<RichUserProfile> updateRichProfile(
    RichUserProfile Function(RichUserProfile current) transform,
  ) async {
    final current = await loadRichProfile();
    final next = transform(current);
    // Skip identical writes so agent probes / no-op transforms stay cheap.
    if (next.encode() == current.encode()) {
      return current;
    }
    await saveRichProfile(next);
    return next;
  }

  @override
  Future<RichUserProfile> updateTodayCheckIn(
    DailyCheckIn Function(DailyCheckIn current) patch, {
    DateTime? now,
    String? eventCategory,
    String? eventSummary,
    String? eventRawRef,
  }) async {
    final day = now ?? DateTime.now();
    final checkDay = DateTime(day.year, day.month, day.day);
    final next = await updateRichProfile((current) {
      var check = current.todayCheckIn;
      if (!_sameCalendarDay(check.localDate, checkDay)) {
        check = DailyCheckIn(localDate: checkDay);
      } else if (check.localDate == null) {
        check = check.copyWith(localDate: checkDay);
      }
      return current.copyWith(todayCheckIn: patch(check));
    });
    if (eventCategory != null &&
        eventSummary != null &&
        eventSummary.trim().isNotEmpty) {
      await logWellnessEvent(
        category: eventCategory,
        summary: eventSummary.trim(),
        rawRef: eventRawRef,
        now: day,
      );
    }
    return next;
  }

  @override
  Future<void> logWellnessEvent({
    required String category,
    required String summary,
    String? rawRef,
    DateTime? now,
  }) async {
    final day = calendarDay(now ?? DateTime.now());
    final userId = await _resolveUserId();
    await refresh(day, userId: userId);
    final user = await (_db.select(_db.users)..where((u) => u.id.equals(userId)))
        .getSingle();
    final stage = StageX.fromWire(user.stage);
    final weekValue = _weekValueFor(stage, user);
    final weekUnit = _weekUnitFor(stage, user) ?? WeekUnitWire.pregnancyWeek;
    final weekStart = day.subtract(Duration(days: day.weekday - 1));
    await _db.into(_db.profileEvents).insert(
          ProfileEventsCompanion.insert(
            userId: userId,
            weekStart: weekStart,
            weekValue: weekValue ?? 0,
            weekUnit: weekUnit,
            category: category,
            summary: summary,
            rawRef: Value(rawRef),
          ),
        );
  }

  static bool _sameCalendarDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
