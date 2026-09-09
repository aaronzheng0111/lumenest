import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/app_copy.dart';
import 'package:ai_mom_baby/data/active_user_store.dart';
import 'package:ai_mom_baby/data/db/database_provider.dart';
import 'package:ai_mom_baby/data/drift_user_profile_repository.dart';
import 'package:ai_mom_baby/domain/stage.dart';
import 'package:ai_mom_baby/features/home/today_task_teaser.dart';
import 'package:ai_mom_baby/providers.dart';
import 'package:ai_mom_baby/tasks/drift_task_card_service.dart';
import 'package:ai_mom_baby/tasks/task_cards.dart';
import 'package:ai_mom_baby/theme/app_theme.dart';

void main() {
  late List<TaskTemplate> templates;

  setUpAll(() async {
    final raw = File('../sdd/10-daily-task-cards/fixtures/task_templates.json')
        .readAsStringSync();
    templates = await loadTaskTemplates(jsonOverride: raw);
  });

  test('T10-01 template match cases', () {
    final cases = jsonDecode(
      File('../sdd/10-daily-task-cards/fixtures/task_match_cases.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    for (final raw in cases['cases'] as List<dynamic>) {
      final c = raw as Map<String, dynamic>;
      final matched = matchTemplates(
        templates: templates,
        stage: StageX.fromWire(c['stage'] as String?),
        weekValue: c['weekValue'] as int?,
      );
      expect(
        matched.map((t) => t.id).toList(),
        (c['expectIds'] as List).cast<String>(),
        reason: '${c['stage']} ${c['weekValue']}',
      );
    }
  });

  test('T10-02 ensureTodayCards is idempotent', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);
    final service = DriftTaskCardService(
      databaseProvider: db,
      profiles: DriftUserProfileRepository(db, activeUserStore: MemoryActiveUserStore()),
      templates: templates,
    );
    final day = DateTime(2026, 9, 9);
    await service.ensureTodayCards(day);
    final first = await service.listToday(day);
    await service.ensureTodayCards(day);
    final second = await service.listToday(day);
    expect(second.length, first.length);
    expect(second.map((e) => e.id), first.map((e) => e.id));
    expect(first, isNotEmpty);
  });

  test('T10-05 toggle DONE/PENDING', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);
    final service = DriftTaskCardService(
      databaseProvider: db,
      profiles: DriftUserProfileRepository(db, activeUserStore: MemoryActiveUserStore()),
      templates: templates,
    );
    final day = DateTime(2026, 9, 9);
    final cards = await service.listToday(day);
    expect(cards, isNotEmpty);
    final id = cards.first.id;
    expect(cards.first.isDone, isFalse);
    await service.toggle(id);
    expect((await service.listToday(day)).first.isDone, isTrue);
    await service.toggle(id);
    expect((await service.listToday(day)).first.isDone, isFalse);
  });

  testWidgets('AC-10-F01 TodayTaskTeaser shows titles and toggle',
      (tester) async {
    const cards = [
      TaskCardView(
        id: 1,
        title: '喝水打卡',
        body: '今天喝够8杯水（习惯，非医嘱）',
        status: 'PENDING',
        templateId: 'prep-water',
      ),
    ];
    final toggled = <int>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayTaskCardsProvider.overrideWith((ref) async => cards),
          taskCardServiceProvider.overrideWith(
            (ref) async => _FakeTaskService(onToggle: toggled.add),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: TodayTaskTeaser()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('喝水打卡'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsOneWidget);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    expect(toggled, [1]);
  });

  testWidgets('AC-10-F01 empty copy when no tasks', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayTaskCardsProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: TodayTaskTeaser()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.noTasksToday), findsOneWidget);
  });
}

class _FakeTaskService implements TaskCardService {
  _FakeTaskService({required this.onToggle});
  final void Function(int id) onToggle;

  @override
  Future<void> ensureTodayCards(DateTime today) async {}

  @override
  Future<List<TaskCardView>> listToday(DateTime today) async => const [];

  @override
  Future<void> toggle(int id) async => onToggle(id);
}
