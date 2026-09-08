import '../domain/agent_role.dart';

/// Tools an agent may invoke (AC-11-B03).
enum AgentTool {
  retrieveKb,
  readContext,
  crisisTemplate,
  upsertHabit,
  toggleTask,
}

/// Static ACL table — unauthorized calls must be rejected by the graph.
abstract final class ToolAcl {
  static const Map<AgentRole, Set<AgentTool>> allowed = {
    AgentRole.xiaonuan: {AgentTool.retrieveKb, AgentTool.readContext},
    AgentRole.lin: {AgentTool.retrieveKb, AgentTool.readContext},
    AgentRole.suxin: {
      AgentTool.readContext,
      AgentTool.crisisTemplate,
      AgentTool.retrieveKb,
    },
    AgentRole.ama: {
      AgentTool.retrieveKb,
      AgentTool.upsertHabit,
      AgentTool.toggleTask,
    },
  };

  static bool canUse(AgentRole role, AgentTool tool) {
    if (role == AgentRole.suxin && tool == AgentTool.retrieveKb) {
      // SUXIN may retrieve only emotion-prefixed chunks — callers filter ids.
      return true;
    }
    return allowed[role]?.contains(tool) ?? false;
  }

  /// SUXIN retrieve_kb filter: only `kb-emotion*` ids.
  static bool suxinMayUseChunk(String chunkId) =>
      chunkId.startsWith('kb-emotion');
}
