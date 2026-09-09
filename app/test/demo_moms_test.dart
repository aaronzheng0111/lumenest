import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/data/demo_moms.dart';
import 'package:ai_mom_baby/data/db/app_database.dart';
import 'package:ai_mom_baby/domain/stage.dart';
import 'package:drift/native.dart';

void main() {
  final today = DateTime(2026, 9, 9);

  test('DemoMoms map to prep / pregnant / delivery stages', () {
    expect(DemoMoms.prep.expectedStage(today), Stage.prep);
    expect(DemoMoms.pregnant.expectedStage(today), Stage.pregnant);
    expect(DemoMoms.postpartum.expectedStage(today), Stage.delivery);
  });

  test('ensureSeedRows inserts three moms with distinct stages', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.ensureSeedRows(today: today);

    final users = await db.select(db.users).get();
    expect(users, hasLength(3));

    Stage stageOf(int id) =>
        StageX.fromWire(users.firstWhere((u) => u.id == id).stage);

    expect(stageOf(1), Stage.prep);
    expect(stageOf(2), Stage.pregnant);
    expect(stageOf(3), Stage.delivery);
    expect(users.firstWhere((u) => u.id == 2).pregnancyWeek, 20);
  });

  test('second ensureSeedRows does not duplicate accounts', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.ensureSeedRows(today: today);
    await db.ensureSeedRows(today: today);
    final users = await db.select(db.users).get();
    expect(users, hasLength(3));
  });
}
