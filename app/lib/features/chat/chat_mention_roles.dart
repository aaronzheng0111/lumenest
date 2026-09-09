import '../../domain/agent_role.dart';

/// Single source for @-mention picker roles (all [AgentRole] values).
///
/// Display names and avatars stay on [AgentRoleX]; pages pass this list into
/// [ChatComposer.mentionRoles] instead of hardcoding role names.
abstract final class ChatMentionRoles {
  static final List<AgentRole> all =
      List<AgentRole>.unmodifiable(AgentRole.values);
}
