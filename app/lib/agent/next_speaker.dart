import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/db/domain_enums.dart';
import '../domain/agent_role.dart';

class RouterRule {
  const RouterRule({required this.any, required this.role});

  final List<String> any;
  final AgentRole role;
}

/// AC-11-B01 / B02 next-speaker decision (no model voting).
AgentRole nextSpeaker({
  required String type,
  required AgentRole soloRole,
  required String userText,
  required bool hasImage,
  required int? riskScore,
  List<RouterRule> routerRules = const [],
  int riskThreshold = 7,
}) {
  if (type == ConversationTypeWire.solo) {
    return soloRole;
  }

  final at = _explicitMention(userText);
  if (at != null) return at;

  final risk = riskScore ?? 0;
  if (risk >= riskThreshold || _hasCrisisPsychWords(userText)) {
    return AgentRole.suxin;
  }
  if (hasImage) return AgentRole.lin;
  if (_hasFoodWords(userText)) return AgentRole.ama;

  // Keyword router (AC-11-B01 step 2) before default.
  for (final rule in routerRules) {
    for (final kw in rule.any) {
      if (userText.contains(kw)) return rule.role;
    }
  }

  return AgentRole.xiaonuan;
}

/// Speakers for one user turn — max 2 (AC-11-B05).
List<AgentRole> resolveSpeakers({
  required String type,
  required AgentRole soloRole,
  required String userText,
  required bool hasImage,
  required int? riskScore,
  List<RouterRule> routerRules = const [],
  int riskThreshold = 7,
}) {
  final primary = nextSpeaker(
    type: type,
    soloRole: soloRole,
    userText: userText,
    hasImage: hasImage,
    riskScore: riskScore,
    routerRules: routerRules,
    riskThreshold: riskThreshold,
  );
  if (type != ConversationTypeWire.group) return [primary];

  // Soft handoff: 小暖 → 苏心 when emotion cues exist but primary stayed 小暖.
  if (primary == AgentRole.xiaonuan &&
      _hasSoftEmotionWords(userText) &&
      (riskScore ?? 0) < riskThreshold) {
    return [AgentRole.xiaonuan, AgentRole.suxin];
  }
  return [primary];
}

AgentRole? _explicitMention(String text) {
  if (text.contains('@林医生') || text.contains('@LIN')) return AgentRole.lin;
  if (text.contains('@苏心') || text.contains('@SUXIN')) return AgentRole.suxin;
  if (text.contains('@阿嬷') || text.contains('@AMA')) return AgentRole.ama;
  if (text.contains('@小暖') || text.contains('@XIAONUAN')) {
    return AgentRole.xiaonuan;
  }
  return null;
}

bool _hasCrisisPsychWords(String text) {
  const words = ['自杀', '不想活', '结束生命', '自伤'];
  return words.any(text.contains);
}

bool _hasFoodWords(String text) {
  const words = ['喂奶', '吐奶', '辅食', '月子', '下奶'];
  return words.any(text.contains);
}

bool _hasSoftEmotionWords(String text) {
  const words = ['焦虑', '失眠', '想哭', '抑郁', '心情不好'];
  return words.any(text.contains);
}

Future<List<RouterRule>> loadRouterRules({
  AssetBundle? bundle,
  String? jsonOverride,
}) async {
  final raw = jsonOverride ??
      await (bundle ?? rootBundle)
          .loadString('assets/fixtures/router_rules.json');
  final map = jsonDecode(raw) as Map<String, dynamic>;
  final list = <RouterRule>[];
  for (final item in map['keyword_to_role'] as List<dynamic>? ?? const []) {
    final m = item as Map<String, dynamic>;
    list.add(
      RouterRule(
        any: (m['any'] as List<dynamic>).cast<String>(),
        role: AgentRoleX.fromWire(m['role'] as String?),
      ),
    );
  }
  return list;
}
