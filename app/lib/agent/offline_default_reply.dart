import '../domain/agent_role.dart';

/// Friendly local reply when LLM key / base URL is not configured.
abstract final class OfflineDefaultReply {
  static String build({
    required AgentRole speaker,
    required String userText,
    String? currentTime,
  }) {
    final name = speaker.displayName;
    if (currentTime != null && currentTime.isNotEmpty) {
      return '我是$name。刚用本地工具查了一下，现在是 $currentTime。'
          '这是未配置模型密钥时的演示回复；配上密钥后我还能陪你细聊。';
    }

    final snippet = _snippet(userText);
    return '我是$name，我在呢。先听到你说：「$snippet」。'
        '这是本地演示模式（未连接模型密钥）——先陪你把话说开；'
        '配置密钥后就能用大模型细聊啦。';
  }

  static String _snippet(String userText, {int maxChars = 40}) {
    final t = userText.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.isEmpty) return '…';
    if (t.length <= maxChars) return t;
    return '${t.substring(0, maxChars)}…';
  }
}
