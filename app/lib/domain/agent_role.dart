enum AgentRole {
  xiaonuan,
  lin,
  suxin,
  ama,
}

extension AgentRoleX on AgentRole {
  /// Wire id used in `/chat?role=`
  String get wireId => switch (this) {
        AgentRole.xiaonuan => 'XIAONUAN',
        AgentRole.lin => 'LIN',
        AgentRole.suxin => 'SUXIN',
        AgentRole.ama => 'AMA',
      };

  /// AC-01-F01 fixed copy.
  String get displayName => switch (this) {
        AgentRole.xiaonuan => '小暖',
        AgentRole.lin => '林医生',
        AgentRole.suxin => '苏心',
        AgentRole.ama => '阿嬷',
      };

  /// All four roles unlocked from Phase 2 (TASK-203).
  bool get isUnlocked => true;

  @Deprecated('Use isUnlocked')
  bool get unlockedInP1 => isUnlocked;

  String get avatarAsset => switch (this) {
        AgentRole.xiaonuan => 'assets/avatars/xiaonuan.png',
        AgentRole.lin => 'assets/avatars/dr-lin.png',
        AgentRole.suxin => 'assets/avatars/suxin.png',
        AgentRole.ama => 'assets/avatars/ama.png',
      };

  static AgentRole fromWire(String? raw) {
    return switch (raw) {
      'LIN' => AgentRole.lin,
      'SUXIN' => AgentRole.suxin,
      'AMA' => AgentRole.ama,
      _ => AgentRole.xiaonuan,
    };
  }
}
