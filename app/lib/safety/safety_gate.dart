import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Outcome of [SafetyGate.inspect].
class SafetyDecision {
  const SafetyDecision.pass()
      : block = false,
        category = null,
        patternId = null,
        reply = null;

  const SafetyDecision.block({
    required this.category,
    required this.patternId,
    required this.reply,
  }) : block = true;

  final bool block;
  final String? category;
  final String? patternId;
  final String? reply;
}

abstract class SafetyGate {
  SafetyDecision inspect(String userText);
}

class PatternRule {
  PatternRule({
    required this.id,
    required this.category,
    required this.type,
    required this.patterns,
  });

  final String id;
  final String category;
  final String type;
  final List<String> patterns;
}

typedef SafetyAuditSink = void Function({
  required String category,
  required String patternId,
  String? conversationId,
});

/// Local rule engine (AC-05). Sync inspect; audit is fire-and-forget.
class LocalSafetyGate implements SafetyGate {
  LocalSafetyGate({
    required List<PatternRule> rules,
    required Map<String, String> replies,
    this.onAudit,
    this.conversationId,
  })  : _rules = rules,
        _replies = replies;

  final List<PatternRule> _rules;
  final Map<String, String> _replies;
  final SafetyAuditSink? onAudit;

  /// Optional context for the next [inspect] audit line (set by chat session).
  String? conversationId;

  /// Loads patterns / replies / hotlines from assets (or [jsonBundle] in tests).
  static Future<LocalSafetyGate> load({
    AssetBundle? bundle,
    Map<String, String>? jsonBundle,
    SafetyAuditSink? onAudit,
  }) async {
    Future<String> read(String assetPath, String key) async {
      if (jsonBundle != null && jsonBundle.containsKey(key)) {
        return jsonBundle[key]!;
      }
      final b = bundle ?? rootBundle;
      return b.loadString(assetPath);
    }

    final patternsRaw = await read(
      'assets/fixtures/safety/safety_patterns.json',
      'patterns',
    );
    final repliesRaw = await read(
      'assets/fixtures/safety/safety_replies.json',
      'replies',
    );
    final hotlinesRaw = await read(
      'assets/fixtures/safety/crisis_hotlines.json',
      'hotlines',
    );

    return LocalSafetyGate.fromDecoded(
      patternsJson: jsonDecode(patternsRaw) as Map<String, dynamic>,
      repliesJson: jsonDecode(repliesRaw) as Map<String, dynamic>,
      hotlinesJson: jsonDecode(hotlinesRaw) as Map<String, dynamic>,
      onAudit: onAudit,
    );
  }

  /// Sync factory for unit tests that already decoded JSON maps.
  factory LocalSafetyGate.fromDecoded({
    required Map<String, dynamic> patternsJson,
    required Map<String, dynamic> repliesJson,
    required Map<String, dynamic> hotlinesJson,
    SafetyAuditSink? onAudit,
  }) {
    final rules = <PatternRule>[];
    for (final raw in patternsJson['patterns'] as List<dynamic>) {
      final m = raw as Map<String, dynamic>;
      rules.add(
        PatternRule(
          id: m['id'] as String,
          category: m['category'] as String,
          type: m['type'] as String,
          patterns: (m['patterns'] as List<dynamic>).cast<String>(),
        ),
      );
    }
    final hotline = hotlinesJson['hotline'] as String? ?? '';
    final hotlineName = hotlinesJson['hotline_name'] as String? ?? '';
    final replies = <String, String>{};
    for (final entry in repliesJson.entries) {
      final body = (entry.value as Map<String, dynamic>)['reply'] as String;
      replies[entry.key] = body
          .replaceAll('{hotline}', hotline)
          .replaceAll('{hotline_name}', hotlineName);
    }
    return LocalSafetyGate(rules: rules, replies: replies, onAudit: onAudit);
  }

  @override
  SafetyDecision inspect(String userText) {
    final normalized = _normalize(userText);
    for (final rule in _rules) {
      if (_matches(rule, normalized, userText)) {
        final reply = _replies[rule.category];
        if (reply == null) {
          debugPrint('SafetyGate missing reply for ${rule.category}');
          continue;
        }
        onAudit?.call(
          category: rule.category,
          patternId: rule.id,
          conversationId: conversationId,
        );
        return SafetyDecision.block(
          category: rule.category,
          patternId: rule.id,
          reply: reply,
        );
      }
    }
    return const SafetyDecision.pass();
  }

  /// P1: case-fold; CJK text is unaffected. Full Unicode NFC deferred.
  static String _normalize(String input) => input.toLowerCase();

  static bool _matches(PatternRule rule, String normalized, String original) {
    for (final p in rule.patterns) {
      if (rule.type == 'contains') {
        if (normalized.contains(p.toLowerCase()) || original.contains(p)) {
          return true;
        }
      } else if (rule.type == 'regexp') {
        final re = RegExp(p, caseSensitive: false, unicode: true);
        if (re.hasMatch(original) || re.hasMatch(normalized)) {
          return true;
        }
      }
    }
    return false;
  }
}
