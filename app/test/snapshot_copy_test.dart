import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/domain/stage.dart';
import 'package:ai_mom_baby/domain/user_profile_snapshot.dart';

void main() {
  test('stage labels are the four frozen strings', () {
    expect(Stage.prep.label, '备孕');
    expect(Stage.pregnant.label, '孕期');
    expect(Stage.delivery.label, '生产');
    expect(Stage.postpartum.label, '产后');
  });

  test('week lines follow AC-01-F01', () {
    expect(const UserProfileSnapshot(stage: Stage.prep).weekLabel, '备孕中');
    expect(
      const UserProfileSnapshot(stage: Stage.pregnant, weekValue: 16).weekLabel,
      '孕16周',
    );
    expect(
      const UserProfileSnapshot(stage: Stage.delivery).weekLabel,
      '待回填分娩日期',
    );
    expect(
      const UserProfileSnapshot(stage: Stage.delivery, weekValue: 2).weekLabel,
      '产褥第2周',
    );
    expect(
      const UserProfileSnapshot(stage: Stage.postpartum, weekValue: 3).weekLabel,
      '产后第3周',
    );
  });
}
