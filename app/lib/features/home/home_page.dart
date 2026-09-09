import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/agent_role.dart';
import '../../domain/user_profile_snapshot.dart';
import '../../providers.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/glass/glass_tab_bar.dart';
import 'role_entry_grid.dart';
import 'today_task_teaser.dart';
import 'widgets/agent_nudge_card.dart';
import 'widgets/health_snapshot_strip.dart';
import 'widgets/hydration_module.dart';
import 'widgets/journey_hero_card.dart';
import 'widgets/meds_pending_card.dart';
import 'widgets/nutrition_focus_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _moodSectionKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(userProfileSnapshotProvider);

    return AtmosphereBackground(
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _HomeBody(
          snapshot: UserProfileSnapshot.fallback,
          moodSectionKey: _moodSectionKey,
          onSelectRole: (role) => _openChat(context, role),
          onOpenProfile: () => _openMe(context),
          onFocusMood: _scrollToMood,
        ),
        data: (snapshot) => _HomeBody(
          snapshot: snapshot,
          moodSectionKey: _moodSectionKey,
          onSelectRole: (role) => _openChat(context, role),
          onOpenProfile: () => _openMe(context),
          onFocusMood: _scrollToMood,
        ),
      ),
    );
  }

  void _openChat(BuildContext context, AgentRole role) {
    Navigator.of(context).pushNamed('/chat?role=${role.wireId}');
  }

  void _openMe(BuildContext context) {
    Navigator.of(context).pushNamed('/me');
  }

  void _scrollToMood() {
    final ctx = _moodSectionKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.snapshot,
    required this.moodSectionKey,
    required this.onSelectRole,
    required this.onOpenProfile,
    required this.onFocusMood,
  });

  final UserProfileSnapshot snapshot;
  final GlobalKey moodSectionKey;
  final ValueChanged<AgentRole> onSelectRole;
  final VoidCallback onOpenProfile;
  final VoidCallback onFocusMood;

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
          AgentNudgeCard(
            snapshot: snapshot,
            onOpenProfile: onOpenProfile,
            onFocusMood: onFocusMood,
          ),
          const SizedBox(height: SpacingTokens.md),
          JourneyHeroCard(snapshot: snapshot),
          const SizedBox(height: SpacingTokens.md),
          RoleEntryGrid(onSelect: onSelectRole),
          const SizedBox(height: SpacingTokens.sectionGap),
          HydrationModule(snapshot: snapshot),
          const SizedBox(height: SpacingTokens.md),
          HealthSnapshotStrip(
            snapshot: snapshot,
            moodFocusKey: moodSectionKey,
          ),
          const SizedBox(height: SpacingTokens.md),
          MedsPendingCard(snapshot: snapshot),
          const SizedBox(height: SpacingTokens.md),
          const TodayCareModule(),
          const SizedBox(height: SpacingTokens.md),
          NutritionFocusCard(snapshot: snapshot),
        ],
      ),
    );
  }
}
