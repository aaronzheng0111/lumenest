import 'tool_acl.dart';

/// User-facing labels for [AgentTool] (tool-status chips, logs, etc.).
///
/// Keep display names here — do not scatter Chinese tool titles in widgets.
abstract final class AgentToolLabels {
  static String displayName(AgentTool tool) => switch (tool) {
        AgentTool.retrieveKb => '检索知识库',
        AgentTool.readContext => '读取对话上下文',
        AgentTool.crisisTemplate => '危机安抚模板',
        AgentTool.upsertHabit => '更新习惯',
        AgentTool.toggleTask => '切换任务',
        AgentTool.getCurrentTime => '获取当前时间',
      };
}
