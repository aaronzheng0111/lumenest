import '../../agent/tool_acl.dart';
import '../../agent/tools/get_current_time_tool.dart';
import '../../agent/tools/update_profile_tool.dart';
import '../../domain/agent_role.dart';

/// Optimistic tool list for the awaiting-reply UI (before the graph returns).
///
/// Order matches graph execution: time tool, then profile update.
List<AgentTool> predictPendingTools({
  required String userText,
  required AgentRole speaker,
}) {
  final pending = <AgentTool>[];
  if (ToolAcl.canUse(speaker, AgentTool.getCurrentTime) &&
      GetCurrentTimeTool.shouldInvoke(userText)) {
    pending.add(AgentTool.getCurrentTime);
  }
  if (ToolAcl.canUse(speaker, AgentTool.updateProfile) &&
      UpdateProfileTool.shouldInvoke(userText)) {
    pending.add(AgentTool.updateProfile);
  }
  return pending;
}
