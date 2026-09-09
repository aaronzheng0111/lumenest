import 'package:drift/drift.dart';

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

  /// P1: ensure single user id=1 and a FREE subscription row.
  Future<void> ensureSeedRows() async {
    final now = DateTime.now().toUtc();
    final existing = await (select(users)..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (existing == null) {
      await into(users).insert(
        UsersCompanion.insert(
          id: const Value(1),
          nickname: const Value('妈妈'),
          stage: const Value(StageWire.prep),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    final subs = await (select(subscriptions)
          ..where((t) => t.userId.equals(1)))
        .get();
    if (subs.isEmpty) {
      await into(subscriptions).insert(
        SubscriptionsCompanion.insert(
          userId: 1,
          plan: PlanWire.free,
          startAt: now,
          dailyChatQuota: 1,
          monthlyReportQuota: 0,
          groupConsultEnabled: const Value(false),
        ),
      );
    }
  }

  Future<Set<String>> listTableNames() async {
    final rows = await customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    ).get();
    return rows.map((r) => r.read<String>('name')).toSet();
  }
}
