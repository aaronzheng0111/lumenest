import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/db/domain_enums.dart';
import '../domain/agent_role.dart';
import '../llm/llm_types.dart';
import 'group_intent_router.dart';

class RouterRule {
  const RouterRule({required this.any, required this.role});

  final List<String> any;
  final AgentRole role;
}

class SpeakerDecision {
  const SpeakerDecision({
    required this.speakers,
    required this.reason,
    this.usedLlmIntent = false,
  });

  final List<AgentRole> speakers;
  final String reason;
  final bool usedLlmIntent;
}

/// Deterministic AC-11-B01 / B02 next-speaker (no model voting).
AgentRole nextSpeaker({
  required String type,
  required AgentRole soloRole,
  required String userText,
  required bool hasImage,
  required int? riskScore,
  List<RouterRule> routerRules = const [],
  int riskThreshold = 7,
}) {
  return _decidePrimary(
    type: type,
    soloRole: soloRole,
    userText: userText,
    hasImage: hasImage,
    riskScore: riskScore,
    routerRules: routerRules,
    riskThreshold: riskThreshold,
  ).role;
}

({AgentRole role, String reason, bool fromMention, bool specialistHit})
    _decidePrimary({
  required String type,
  required AgentRole soloRole,
  required String userText,
  required bool hasImage,
  required int? riskScore,
  List<RouterRule> routerRules = const [],
  int riskThreshold = 7,
}) {
  if (type == ConversationTypeWire.solo) {
    return (
      role: soloRole,
      reason: 'solo',
      fromMention: false,
      specialistHit: false,
    );
  }

  final at = _explicitMention(userText);
  if (at != null) {
    return (
      role: at,
      reason: 'mention',
      fromMention: true,
      specialistHit: at != AgentRole.xiaonuan,
    );
  }

  final risk = riskScore ?? 0;
  if (risk >= riskThreshold || _hasCrisisPsychWords(userText)) {
    return (
      role: AgentRole.suxin,
      reason: 'crisis_or_risk',
      fromMention: false,
      specialistHit: true,
    );
  }
  if (hasImage) {
    return (
      role: AgentRole.lin,
      reason: 'image',
      fromMention: false,
      specialistHit: true,
    );
  }
  if (_hasFoodWords(userText)) {
    return (
      role: AgentRole.ama,
      reason: 'food_words',
      fromMention: false,
      specialistHit: true,
    );
  }

  for (final rule in routerRules) {
    for (final kw in rule.any) {
      if (userText.contains(kw)) {
        return (
          role: rule.role,
          reason: 'keyword:$kw',
          fromMention: false,
          specialistHit: rule.role != AgentRole.xiaonuan,
        );
      }
    }
  }

  return (
    role: AgentRole.xiaonuan,
    reason: 'default_xiaonuan',
    fromMention: false,
    specialistHit: false,
  );
}

/// Speakers for one user turn — max 2 (AC-11-B05). Sync / offline path.
List<AgentRole> resolveSpeakers({
  required String type,
  required AgentRole soloRole,
  required String userText,
  required bool hasImage,
  required int? riskScore,
  List<RouterRule> routerRules = const [],
  int riskThreshold = 7,
}) {
  return resolveSpeakersDetailed(
    type: type,
    soloRole: soloRole,
    userText: userText,
    hasImage: hasImage,
    riskScore: riskScore,
    routerRules: routerRules,
    riskThreshold: riskThreshold,
  ).speakers;
}

SpeakerDecision resolveSpeakersDetailed({
  required String type,
  required AgentRole soloRole,
  required String userText,
  required bool hasImage,
  required int? riskScore,
  List<RouterRule> routerRules = const [],
  int riskThreshold = 7,
  AgentRole? llmOverride,
  bool usedLlmIntent = false,
}) {
  final primary = _decidePrimary(
    type: type,
    soloRole: soloRole,
    userText: userText,
    hasImage: hasImage,
    riskScore: riskScore,
    routerRules: routerRules,
    riskThreshold: riskThreshold,
  );

  var role = primary.role;
  var reason = primary.reason;
  var fromMention = primary.fromMention;
  var specialistHit = primary.specialistHit;

  if (llmOverride != null &&
      type == ConversationTypeWire.group &&
      reason == 'default_xiaonuan') {
    role = llmOverride;
    reason = 'llm_intent:${llmOverride.wireId}';
    specialistHit = llmOverride != AgentRole.xiaonuan;
    fromMention = false;
  }

  if (type != ConversationTypeWire.group) {
    return SpeakerDecision(speakers: [role], reason: reason);
  }

  // Crisis / explicit @ → that role alone.
  if (reason == 'crisis_or_risk' || fromMention) {
    return SpeakerDecision(
      speakers: [role],
      reason: reason,
      usedLlmIntent: usedLlmIntent,
    );
  }

  // Consult assignment: 小暖先接住，再交给专科（最多 2 人）。
  if (specialistHit && role != AgentRole.xiaonuan) {
    return SpeakerDecision(
      speakers: [AgentRole.xiaonuan, role],
      reason: 'consult:$reason',
      usedLlmIntent: usedLlmIntent,
    );
  }

  // Soft emotion with no specialist keyword → 小暖 + 苏心.
  if (role == AgentRole.xiaonuan &&
      _hasSoftEmotionWords(userText) &&
      (riskScore ?? 0) < riskThreshold) {
    return SpeakerDecision(
      speakers: [AgentRole.xiaonuan, AgentRole.suxin],
      reason: 'soft_emotion',
      usedLlmIntent: usedLlmIntent,
    );
  }

  return SpeakerDecision(
    speakers: [role],
    reason: reason,
    usedLlmIntent: usedLlmIntent,
  );
}

/// GROUP path: deterministic rules first; optional one-shot intent LLM if miss.
Future<SpeakerDecision> resolveSpeakersAsync({
  required String type,
  required AgentRole soloRole,
  required String userText,
  required bool hasImage,
  required int? riskScore,
  List<RouterRule> routerRules = const [],
  int riskThreshold = 7,
  LlmClient? intentLlm,
}) async {
  final base = resolveSpeakersDetailed(
    type: type,
    soloRole: soloRole,
    userText: userText,
    hasImage: hasImage,
    riskScore: riskScore,
    routerRules: routerRules,
    riskThreshold: riskThreshold,
  );

  final needsIntent = type == ConversationTypeWire.group &&
      base.reason == 'default_xiaonuan' &&
      intentLlm != null &&
      intentLlm.canCallRemote &&
      userText.trim().isNotEmpty;

  if (!needsIntent) return base;

  final classified = await GroupIntentRouter.classify(
    llm: intentLlm,
    userText: userText,
  );
  if (classified == AgentRole.xiaonuan) {
    return SpeakerDecision(
      speakers: base.speakers,
      reason: 'llm_intent:XIAONUAN',
      usedLlmIntent: true,
    );
  }

  return resolveSpeakersDetailed(
    type: type,
    soloRole: soloRole,
    userText: userText,
    hasImage: hasImage,
    riskScore: riskScore,
    routerRules: routerRules,
    riskThreshold: riskThreshold,
    llmOverride: classified,
    usedLlmIntent: true,
  );
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
  const words = ['喂奶', '吐奶', '辅食', '月子', '下奶', '哺乳', '母乳', '奶粉', '涨奶'];
  return words.any(text.contains);
}

bool _hasSoftEmotionWords(String text) {
  const words = [
    '焦虑',
    '失眠',
    '想哭',
    '抑郁',
    '心情不好',
    '压力大',
    '有点慌',
    '睡不好',
    '难过',
  ];
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
