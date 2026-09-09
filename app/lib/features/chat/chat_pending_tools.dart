import '../../agent/tool_acl.dart';
import '../../agent/tools/get_current_time_tool.dart';
import '../../domain/agent_role.dart';

/// Optimistic tool list for the awaiting-reply UI (before the graph returns).
List<AgentTool> predictPendingTools({
  required String userText,
  required AgentRole speaker,
}) {
  if (!ToolAcl.canUse(speaker, AgentTool.getCurrentTime)) {
    return const [];
  }
  if (!GetCurrentTimeTool.shouldInvoke(userText)) return const [];
  return const [AgentTool.getCurrentTime];
}
