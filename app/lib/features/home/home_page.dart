import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/agent_role.dart';
import '../../domain/user_profile_snapshot.dart';
import '../../providers.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/glass/glass_tab_bar.dart';
import 'home_stage_header.dart';
import 'role_entry_grid.dart';
import 'today_task_teaser.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(userProfileSnapshotProvider);

    return AtmosphereBackground(
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _HomeBody(
          snapshot: UserProfileSnapshot.fallback,
          onSelectRole: (role) => _openChat(context, role),
        ),
        data: (snapshot) => _HomeBody(
          snapshot: snapshot,
          onSelectRole: (role) => _openChat(context, role),
        ),
      ),
    );
  }

  void _openChat(BuildContext context, AgentRole role) {
    Navigator.of(context).pushNamed('/chat?role=${role.wireId}');
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.snapshot,
    required this.onSelectRole,
  });

  final UserProfileSnapshot snapshot;
  final ValueChanged<AgentRole> onSelectRole;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        SpacingTokens.pageMargin,
        MediaQuery.paddingOf(context).top + SpacingTokens.lg,
        SpacingTokens.pageMargin,
        MediaQuery.paddingOf(context).bottom +
            GlassTabBar.height +
            SpacingTokens.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeStageHeader(snapshot: snapshot),
          const SizedBox(height: SpacingTokens.sectionGap),
          RoleEntryGrid(onSelect: onSelectRole),
          const SizedBox(height: SpacingTokens.sectionGap),
          const TodayTaskTeaser(),
        ],
      ),
    );
  }
}
