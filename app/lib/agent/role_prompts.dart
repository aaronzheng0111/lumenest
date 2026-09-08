import 'package:flutter/services.dart';

import '../domain/agent_role.dart';

/// Loads per-role system prompts (T11-01). Xiaonuan stays shared with module 08.
abstract final class RolePrompts {
  static String assetPath(AgentRole role) => switch (role) {
        AgentRole.xiaonuan =>
          'assets/fixtures/prompts/xiaonuan_system_prompt.txt',
        AgentRole.lin => 'assets/fixtures/prompts/lin_system_prompt.txt',
        AgentRole.suxin => 'assets/fixtures/prompts/suxin_system_prompt.txt',
        AgentRole.ama => 'assets/fixtures/prompts/ama_system_prompt.txt',
      };

  static Future<String> load(AgentRole role, {AssetBundle? bundle}) {
    return (bundle ?? rootBundle).loadString(assetPath(role));
  }
}
