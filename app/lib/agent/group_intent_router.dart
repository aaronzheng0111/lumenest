import '../domain/agent_role.dart';
import '../llm/llm_types.dart';

/// Lightweight GROUP intent classifier used only when deterministic rules miss.
///
/// Not "model voting" (AC-11-B02): a single constrained label call that returns
/// one [AgentRole]. Offline / errors fall back to 小暖.
abstract final class GroupIntentRouter {
  static const _system = '''
你是孕产群聊会诊的意图路由器。根据用户一句话，只输出一个角色 ID（大写），不要解释、不要标点：
XIAONUAN — 日常陪伴、闲聊、自我介绍、时间、泛泛安慰
LIN — 孕产医疗科普、症状、产检、用药、胎儿相关
SUXIN — 情绪心理、焦虑失眠、压力崩溃
AMA — 喂养、月子、辅食、育儿生活照料
''';

  static Future<AgentRole> classify({
    required LlmClient llm,
    required String userText,
  }) async {
    final text = userText.trim();
    if (text.isEmpty || !llm.canCallRemote) return AgentRole.xiaonuan;

    final result = await llm.complete(
      messages: [
        const ChatMessageWire(role: 'system', content: _system),
        ChatMessageWire(role: 'user', content: text),
      ],
      requestId: 'grp-intent-${DateTime.now().microsecondsSinceEpoch}',
    );

    if (result.status != LlmStatus.ok) return AgentRole.xiaonuan;
    return parseRoleLabel(result.content);
  }

  /// Parses a model label into a role; unknown → 小暖.
  static AgentRole parseRoleLabel(String? raw) {
    final t = (raw ?? '').trim().toUpperCase();
    if (t.isEmpty) return AgentRole.xiaonuan;
    if (t.contains('LIN') || t.contains('林医生')) return AgentRole.lin;
    if (t.contains('SUXIN') || t.contains('苏心')) return AgentRole.suxin;
    if (t.contains('AMA') || t.contains('阿嬷')) return AgentRole.ama;
    if (t.contains('XIAONUAN') || t.contains('小暖')) return AgentRole.xiaonuan;
    return AgentRole.xiaonuan;
  }
}
