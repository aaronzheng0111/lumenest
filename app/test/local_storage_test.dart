import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:ai_mom_baby/data/db/app_database.dart';
import 'package:ai_mom_baby/data/db/database_provider.dart';

void main() {
  test('AC-02-B02 required tables exist', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();
    final names = await db.listTableNames();
    expect(
      names.intersection(AppDatabase.requiredTableNames),
      AppDatabase.requiredTableNames,
    );
    expect(names.contains('objectbox'), isFalse);
  });

  test('AC-02-B03 seed creates three demo moms with FREE subs', () async {
    final provider = DriftDatabaseProvider(executor: NativeDatabase.memory());
    addTearDown(provider.close);
    await provider.init();
    await provider.init();

    final users = await provider.db.select(provider.db.users).get();
    expect(users, hasLength(3));
    expect(users.map((u) => u.id).toSet(), {1, 2, 3});
    expect(users.map((u) => u.nickname).toSet(), {
      '晓晓·备孕',
      '林林·孕期',
      '安安·产后',
    });

    final subs = await provider.db.select(provider.db.subscriptions).get();
    expect(subs, hasLength(3));
    expect(subs.map((s) => s.userId).toSet(), {1, 2, 3});
    expect(subs.every((s) => s.plan == 'FREE'), isTrue);
  });

  test('T02-04 insert and query messages', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.ensureSeedRows();

    final convId = await db.into(db.conversations).insert(
          ConversationsCompanion.insert(
            userId: 1,
            role: 'XIAONUAN',
            type: 'SOLO',
            createdAt: DateTime.utc(2026, 9, 8),
          ),
        );

    await db.into(db.messages).insert(
          MessagesCompanion.insert(
            conversationId: convId,
            role: 'user',
            content: '今天胎动正常吗',
            createdAt: DateTime.utc(2026, 9, 8, 12),
          ),
        );

    final rows = await (db.select(db.messages)
          ..where((m) => m.conversationId.equals(convId)))
        .get();
    expect(rows, hasLength(1));
    expect(rows.single.content, '今天胎动正常吗');
    expect(rows.single.role, 'user');
  });

  test('T02-05 v1 to v2 empty migration keeps users', () async {
    final sqlite = sqlite3.openInMemory();
    addTearDown(sqlite.dispose);

    final v1 = AppDatabase(
      NativeDatabase.opened(sqlite, closeUnderlyingOnClose: false),
      schemaVersionOverride: 1,
    );
    await v1.customSelect('SELECT 1').get();
    await v1.into(v1.users).insert(
          UsersCompanion.insert(
            id: const Value(1),
            nickname: const Value('验收甲'),
            stage: const Value('PREP'),
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
    await v1.close();

    final v2 = AppDatabase(
      NativeDatabase.opened(sqlite, closeUnderlyingOnClose: false),
    );
    addTearDown(v2.close);
    await v2.customSelect('SELECT 1').get();
    final users = await v2.select(v2.users).get();
    expect(users, hasLength(1));
    expect(users.single.id, 1);
    expect(users.single.nickname, '验收甲');
  });

  test('AC-02-B05 L3/L4 markers present on sensitive fields', () {
    final source = File('lib/data/db/tables.dart').readAsStringSync();
    expect(source.contains('L3 sensitive health field'), isTrue);
    expect(source.contains('L3 sensitive content'), isTrue);
    expect(source.contains('L3 sensitive summary'), isTrue);
    expect(source.contains('L4 audit-sensitive score'), isTrue);
  });

  test('AC-02-F01 features must not import generated Drift', () {
    final root = Directory('lib/features');
    final offenders = <String>[];
    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final text = entity.readAsStringSync();
      if (text.contains('.g.dart') || text.contains('package:drift/')) {
        offenders.add(entity.path);
      }
    }
    expect(offenders, isEmpty, reason: offenders.join(', '));
  });
}
