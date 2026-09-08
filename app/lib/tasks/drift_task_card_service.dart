import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/db/app_database.dart';
import '../data/db/database_provider.dart';
import '../data/db/domain_enums.dart';
import '../data/user_profile_repository.dart';
import '../domain/stage.dart';
import 'task_cards.dart';

class DriftTaskCardService implements TaskCardService {
  DriftTaskCardService({
    required DatabaseProvider databaseProvider,
    required UserProfileRepository profiles,
    required List<TaskTemplate> templates,
  })  : _dbProvider = databaseProvider,
        _profiles = profiles,
        _templates = templates;

  final DatabaseProvider _dbProvider;
  final UserProfileRepository _profiles;
  final List<TaskTemplate> _templates;

  AppDatabase get _db => _dbProvider.db;

  static DateTime calendarDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  @override
  Future<void> ensureTodayCards(DateTime today) async {
    final day = calendarDay(today);
    final existing = await (_db.select(_db.taskCards)
          ..where(
            (t) => t.userId.equals(1) & t.localDate.equals(day),
          ))
        .get();
    if (existing.isNotEmpty) return;

    final snapshot = await _profiles.getSnapshot(today: day);
    final matched = matchTemplates(
      templates: _templates,
      stage: snapshot.stage,
      weekValue: snapshot.weekValue,
    );
    for (final tmpl in matched) {
      final payload = jsonEncode({
        'templateId': tmpl.id,
        'title': tmpl.title,
        'body': tmpl.body,
      });
      await _db.into(_db.taskCards).insert(
            TaskCardsCompanion.insert(
              userId: 1,
              localDate: day,
              stage: _stageWire(snapshot.stage),
              weekValue: Value(snapshot.weekValue),
              payloadJson: payload,
              status: TaskStatusWire.pending,
            ),
          );
    }
  }

  @override
  Future<List<TaskCardView>> listToday(DateTime today) async {
    final day = calendarDay(today);
    await ensureTodayCards(day);
    final rows = await (_db.select(_db.taskCards)
          ..where((t) => t.userId.equals(1) & t.localDate.equals(day))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    return rows.map(_toView).toList();
  }

  @override
  Future<void> toggle(int id) async {
    final row = await (_db.select(_db.taskCards)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return;
    final next = row.status == TaskStatusWire.done
        ? TaskStatusWire.pending
        : TaskStatusWire.done;
    await (_db.update(_db.taskCards)..where((t) => t.id.equals(id))).write(
      TaskCardsCompanion(status: Value(next)),
    );
  }

  TaskCardView _toView(TaskCard row) {
    var title = '任务';
    var body = '';
    var templateId = '';
    try {
      final map = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      title = map['title'] as String? ?? title;
      body = map['body'] as String? ?? '';
      templateId = map['templateId'] as String? ?? '';
    } catch (_) {}
    return TaskCardView(
      id: row.id,
      title: title,
      body: body,
      status: row.status,
      templateId: templateId,
    );
  }

  static String _stageWire(Stage stage) => switch (stage) {
        Stage.prep => StageWire.prep,
        Stage.pregnant => StageWire.pregnant,
        Stage.delivery => StageWire.delivery,
        Stage.postpartum => StageWire.postpartum,
      };
}
