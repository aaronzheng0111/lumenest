import 'package:drift/drift.dart';

import '../demo_moms.dart';
import '../../domain/stage.dart';
import '../../domain/stage_resolver.dart';
import 'domain_enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Conversations,
    Messages,
    ProfileEvents,
    TaskCards,
    Subscriptions,
    SchemaMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e, {int? schemaVersionOverride})
      : _schemaVersionOverride = schemaVersionOverride;

  final int? _schemaVersionOverride;

  /// Current schema. Bump with a no-op/data migration in [migration].
  static const int currentSchemaVersion = 3;

  /// Tables required by AC-02-B02 (+ schema_meta).
  static const requiredTableNames = {
    'users',
    'conversations',
    'messages',
    'profile_events',
    'task_cards',
    'subscriptions',
    'schema_meta',
  };

  @override
  int get schemaVersion => _schemaVersionOverride ?? currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _writeSchemaMeta(schemaVersion);
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // v1 → v2: empty scaffold (T02-05). Keep users intact.
          if (from < 2 && to >= 2) {
            // no-op
          }
          // v2 → v3: rich profile JSON + multi-account ready.
          if (from < 3 && to >= 3) {
            final cols = await customSelect("PRAGMA table_info('users')").get();
            final names = cols.map((r) => r.read<String>('name')).toSet();
            if (!names.contains('profile_json')) {
              await m.addColumn(users, users.profileJson);
            }
          }
          await _writeSchemaMeta(to);
        },
      );

  Future<void> _writeSchemaMeta(int version) async {
    await into(schemaMeta).insertOnConflictUpdate(
      SchemaMetaCompanion.insert(id: const Value(1), version: version),
    );
  }

  /// Ensures three demo moms (备孕 / 孕期 / 产后) + FREE subscriptions.
  ///
  /// Missing ids are inserted. Existing rows are left alone so real edits
  /// survive re-init (except a pristine default `妈妈` id=1 is upgraded once).
  Future<void> ensureSeedRows({DateTime? today}) async {
    final now = DateTime.now().toUtc();
    final day = calendarDay(today ?? DateTime.now());

    for (final mom in DemoMoms.all) {
      final row =
          await (select(users)..where((t) => t.id.equals(mom.id)))
              .getSingleOrNull();
      if (row == null) {
        await _insertDemoMom(mom, day: day, now: now);
      } else if (mom.id == 1 && _isPristineDefaultMom(row)) {
        await _upgradePristineDefaultToPrep(mom, day: day, now: now);
      }
      await _ensureFreeSubscription(mom.id, now: now);
    }
  }

  bool _isPristineDefaultMom(User row) {
    return row.nickname == '妈妈' &&
        row.dueDate == null &&
        row.birthDate == null &&
        row.lastMenstruationDate == null &&
        (row.profileJson.isEmpty || row.profileJson == '{}');
  }

  Future<void> _upgradePristineDefaultToPrep(
    DemoMom mom, {
    required DateTime day,
    required DateTime now,
  }) async {
    final dates = mom.datesFor(day);
    final resolved = resolveStage(
      today: day,
      dueDate: dates.due,
      birthDate: dates.birth,
      lastMenstruationDate: dates.lmp,
    );
    await (update(users)..where((u) => u.id.equals(mom.id))).write(
      UsersCompanion(
        nickname: Value(mom.nickname),
        stage: Value(_stageWire(resolved.stage)),
        lastMenstruationDate: Value(dates.lmp),
        dueDate: Value(dates.due),
        birthDate: Value(dates.birth),
        pregnancyWeek: Value(resolved.pregnancyWeek),
        postpartumWeek: Value(resolved.postpartumWeek),
        profileJson: Value(mom.richProfile.encode()),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> _insertDemoMom(
    DemoMom mom, {
    required DateTime day,
    required DateTime now,
  }) async {
    final dates = mom.datesFor(day);
    final resolved = resolveStage(
      today: day,
      dueDate: dates.due,
      birthDate: dates.birth,
      lastMenstruationDate: dates.lmp,
    );
    await into(users).insert(
      UsersCompanion.insert(
        id: Value(mom.id),
        nickname: Value(mom.nickname),
        stage: Value(_stageWire(resolved.stage)),
        lastMenstruationDate: Value(dates.lmp),
        dueDate: Value(dates.due),
        birthDate: Value(dates.birth),
        pregnancyWeek: Value(resolved.pregnancyWeek),
        postpartumWeek: Value(resolved.postpartumWeek),
        profileJson: Value(mom.richProfile.encode()),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> _ensureFreeSubscription(int userId, {required DateTime now}) async {
    final subs = await (select(subscriptions)
          ..where((t) => t.userId.equals(userId)))
        .get();
    if (subs.isNotEmpty) return;
    await into(subscriptions).insert(
      SubscriptionsCompanion.insert(
        userId: userId,
        plan: PlanWire.free,
        startAt: now,
        dailyChatQuota: 1,
        monthlyReportQuota: 0,
        groupConsultEnabled: const Value(false),
      ),
    );
  }

  static String _stageWire(Stage stage) => switch (stage) {
        Stage.prep => StageWire.prep,
        Stage.pregnant => StageWire.pregnant,
        Stage.delivery => StageWire.delivery,
        Stage.postpartum => StageWire.postpartum,
      };

  Future<Set<String>> listTableNames() async {
    final rows = await customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    ).get();
    return rows.map((r) => r.read<String>('name')).toSet();
  }
}
