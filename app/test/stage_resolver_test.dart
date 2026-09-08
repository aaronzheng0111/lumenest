import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/domain/stage.dart';
import 'package:ai_mom_baby/domain/stage_resolver.dart';
import 'package:ai_mom_baby/domain/week_calculator.dart';

DateTime? _parseDate(dynamic raw) {
  if (raw == null) return null;
  final parts = (raw as String).split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

void main() {
  final fixtureFile = File(
    '../sdd/03-user-profile-and-stage/fixtures/stage_cases.json',
  );

  test('AC-03-B01 stage_cases.json 100% pass', () {
    final json =
        jsonDecode(fixtureFile.readAsStringSync()) as Map<String, dynamic>;
    final cases = json['cases'] as List<dynamic>;
    expect(cases, isNotEmpty);

    for (final raw in cases) {
      final c = raw as Map<String, dynamic>;
      final result = resolveStage(
        today: _parseDate(c['today'])!,
        dueDate: _parseDate(c['dueDate']),
        birthDate: _parseDate(c['birthDate']),
        lastMenstruationDate: _parseDate(c['lastMenstruationDate']),
      );
      final id = c['id'];
      expect(
        result.stage,
        StageX.fromWire(c['expectStage'] as String?),
        reason: '$id stage',
      );
      expect(result.weekValue, c['expectWeekValue'], reason: '$id weekValue');
      expect(result.weekUnit, c['expectWeekUnit'], reason: '$id weekUnit');
    }
  });

  test('WeekCalculator pregnancy week matches resolver', () {
    final week = WeekCalculator.pregnancyWeek(
      today: DateTime(2026, 9, 7),
      lastMenstruationDate: DateTime(2026, 3, 12),
      dueDate: DateTime(2026, 12, 16),
    );
    expect(week, 26);
  });

  test('WeekCalculator postpartum week', () {
    expect(WeekCalculator.postpartumWeek(daysSinceBirth: 42), 7);
    expect(WeekCalculator.postpartumWeek(daysSinceBirth: 43), 7);
    expect(WeekCalculator.postpartumWeek(daysSinceBirth: 10), 2);
  });
}
