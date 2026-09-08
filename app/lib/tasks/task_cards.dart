import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/stage.dart';

class TaskTemplate {
  const TaskTemplate({
    required this.id,
    required this.stage,
    required this.title,
    required this.body,
    this.weekMin,
    this.weekMax,
  });

  final String id;
  final Stage stage;
  final int? weekMin;
  final int? weekMax;
  final String title;
  final String body;

  factory TaskTemplate.fromJson(Map<String, dynamic> json) {
    return TaskTemplate(
      id: json['id'] as String,
      stage: StageX.fromWire(json['stage'] as String?),
      weekMin: json['weekMin'] as int?,
      weekMax: json['weekMax'] as int?,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

class TaskCardView {
  const TaskCardView({
    required this.id,
    required this.title,
    required this.body,
    required this.status,
    required this.templateId,
  });

  final int id;
  final String title;
  final String body;

  /// PENDING | DONE | SKIPPED
  final String status;
  final String templateId;

  bool get isDone => status == 'DONE';
}

/// Pure match (AC-10-B01 / T10-01).
List<TaskTemplate> matchTemplates({
  required List<TaskTemplate> templates,
  required Stage stage,
  required int? weekValue,
}) {
  return templates.where((t) {
    if (t.stage != stage) return false;
    if (t.weekMin == null && t.weekMax == null) {
      // PREP-style: stage-only match.
      return true;
    }
    if (weekValue == null) return false;
    final min = t.weekMin ?? weekValue;
    final max = t.weekMax ?? weekValue;
    return weekValue >= min && weekValue <= max;
  }).toList();
}

Future<List<TaskTemplate>> loadTaskTemplates({
  AssetBundle? bundle,
  String? jsonOverride,
}) async {
  final raw = jsonOverride ??
      await (bundle ?? rootBundle)
          .loadString('assets/fixtures/tasks/task_templates.json');
  final map = jsonDecode(raw) as Map<String, dynamic>;
  return [
    for (final item in map['templates'] as List<dynamic>)
      TaskTemplate.fromJson(item as Map<String, dynamic>),
  ];
}

abstract class TaskCardService {
  Future<void> ensureTodayCards(DateTime today);

  Future<List<TaskCardView>> listToday(DateTime today);

  Future<void> toggle(int id);
}
