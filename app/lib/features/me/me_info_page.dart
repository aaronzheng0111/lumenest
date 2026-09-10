import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_copy.dart';
import '../../domain/effective_journey.dart';
import '../../domain/user_profile_snapshot.dart';
import '../../providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_tab_bar.dart';
import '../../widgets/glass/sliver_collapsing_glass_header.dart';
import 'health_section_page.dart';
import 'lifestyle_section_page.dart';
import 'medications_section_page.dart';
import 'personal_section_page.dart';
import 'preferences_section_page.dart';
import 'pregnancy_section_page.dart';
import 'privacy_sheet.dart';
import 'profile_ui_shared.dart';

class MeInfoPage extends ConsumerWidget {
  const MeInfoPage({super.key});

  static const double _headerExpanded = 180;
  static const double _headerCollapsed = 56;

  Future<void> _openSection(
    BuildContext context,
    WidgetRef ref,
    Widget page,
  ) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => page),
    );
    if (saved == true) {
      ref.invalidate(userProfileSnapshotProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(userProfileSnapshotProvider);
    final accountsAsync = ref.watch(localAccountsProvider);
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomPad = MediaQuery.paddingOf(context).bottom +
        GlassTabBar.height +
        SpacingTokens.xl;
    final snap = snapshotAsync.maybeWhen(
      data: (s) => s,
      orElse: () => UserProfileSnapshot.fallback,
    );

    return AtmosphereBackground(
      child: CustomScrollView(
        key: const Key('me_scroll'),
        slivers: [
          SliverCollapsingGlassHeader(
            topInset: topInset + SpacingTokens.sm,
            expandedBodyHeight: _headerExpanded,
            collapsedBodyHeight: _headerCollapsed,
            horizontalPadding: SpacingTokens.pageMargin,
            expanded: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '我的',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: SpacingTokens.lg),
                if (snapshotAsync.isLoading)
                  const GlassContainer(
                    fill: GlassFill.heavy,
                    borderRadius: RadiusTokens.borderXl,
                    padding: EdgeInsets.all(SpacingTokens.xl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  _ProfileHero(
                    snapshot: snap,
                    onSwitchAccount: () => _showAccountSwitcher(context, ref),
                  ),
              ],
            ),
            collapsed: Align(
              alignment: Alignment.center,
              child: _ProfilePinnedBar(
                snapshot: snap,
                onSwitchAccount: () => _showAccountSwitcher(context, ref),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              SpacingTokens.pageMargin,
              SpacingTokens.md,
              SpacingTokens.pageMargin,
              bottomPad,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TodayStrip(snapshotAsync: snapshotAsync),
                  const SizedBox(height: SpacingTokens.lg),
                  Text('档案', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: SpacingTokens.sm),
                  snapshotAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (snap) => Column(
                      children: [
                        ProfileSectionCard(
                          tileKey: const Key('profile_section_personal'),
                          icon: Icons.person_outline_rounded,
                          title: '个人',
                          summary: personalSummary(snap),
                          onTap: () => _openSection(
                            context,
                            ref,
                            const PersonalSectionPage(),
                          ),
                        ),
                        ProfileSectionCard(
                          tileKey: const Key('profile_section_pregnancy'),
                          icon: Icons.pregnant_woman_outlined,
                          title: '孕期',
                          summary: pregnancySummary(snap),
                          onTap: () => _openSection(
                            context,
                            ref,
                            const PregnancySectionPage(),
                          ),
                        ),
                        ProfileSectionCard(
                          tileKey: const Key('profile_section_health'),
                          icon: Icons.favorite_outline_rounded,
                          title: '健康',
                          summary: healthSummary(snap),
                          sensitive: true,
                          onTap: () => _openSection(
                            context,
                            ref,
                            const HealthSectionPage(),
                          ),
                        ),
                        ProfileSectionCard(
                          tileKey: const Key('profile_section_meds'),
                          icon: Icons.medication_outlined,
                          title: '用药与过敏',
                          summary: medicationsSummary(snap),
                          sensitive: true,
                          onTap: () => _openSection(
                            context,
                            ref,
                            const MedicationsSectionPage(),
                          ),
                        ),
                        ProfileSectionCard(
                          tileKey: const Key('profile_section_lifestyle'),
                          icon: Icons.spa_outlined,
                          title: '生活方式',
                          summary: lifestyleSummary(snap),
                          onTap: () => _openSection(
                            context,
                            ref,
                            const LifestyleSectionPage(),
                          ),
                        ),
                        ProfileSectionCard(
                          tileKey: const Key('profile_section_prefs'),
                          icon: Icons.tune_rounded,
                          title: '偏好',
                          summary: preferencesSummary(snap),
                          onTap: () => _openSection(
                            context,
                            ref,
                            const PreferencesSectionPage(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  Text(
                    '账号与隐私',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  GlassContainer(
                    fill: GlassFill.heavy,
                    borderRadius: RadiusTokens.borderXl,
                    padding: const EdgeInsets.symmetric(
                      vertical: SpacingTokens.sm,
                    ),
                    child: Column(
                      children: [
                        _MeTile(
                          tileKey: const Key('me_accounts'),
                          icon: Icons.switch_account_outlined,
                          title: accountsAsync.maybeWhen(
                            data: (list) => '切换账号（${list.length}）',
                            orElse: () => '切换账号',
                          ),
                          onTap: () => _showAccountSwitcher(context, ref),
                        ),
                        const Divider(indent: 56),
                        _MeTile(
                          tileKey: const Key('me_privacy'),
                          icon: Icons.privacy_tip_outlined,
                          title: AppCopy.privacyTitle,
                          onTap: () => showPrivacySheet(context, ref),
                        ),
                        const Divider(indent: 56),
                        _MeTile(
                          tileKey: const Key('me_export'),
                          icon: Icons.ios_share_rounded,
                          title: AppCopy.exportData,
                          onTap: () => _export(context, ref),
                        ),
                        const Divider(indent: 56),
                        _MeTile(
                          tileKey: const Key('me_delete'),
                          icon: Icons.delete_outline_rounded,
                          title: AppCopy.deleteData,
                          onTap: () => _delete(context, ref),
                        ),
                        const Divider(indent: 56),
                        _MeTile(
                          tileKey: const Key('me_clear_chat'),
                          icon: Icons.chat_bubble_outline_rounded,
                          title: AppCopy.clearChatHistory,
                          onTap: () => _clearChatHistory(context, ref),
                        ),
                        const Divider(indent: 56),
                        _MeTile(
                          tileKey: const Key('me_clear_summaries'),
                          icon: Icons.history_toggle_off_rounded,
                          title: AppCopy.clearSummaries,
                          onTap: () => _clearSummaries(context, ref),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAccountSwitcher(BuildContext context, WidgetRef ref) async {
    final accounts = await ref.read(localAccountsProvider.future);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return GlassContainer(
          fill: GlassFill.heavy,
          borderRadius: RadiusTokens.sheetTop,
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.lg,
            SpacingTokens.lg,
            SpacingTokens.lg,
            SpacingTokens.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('本地账号', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                '每位用户的档案与对话相互隔离，保存在本机。',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: SpacingTokens.md),
              for (final a in accounts)
                ListTile(
                  key: Key('account_${a.id}'),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.glassRoseSoft,
                    child: Text(
                      _initial(a.nickname),
                      style: const TextStyle(color: AppColors.primaryDeep),
                    ),
                  ),
                  title: Text(a.nickname),
                  subtitle: Text(
                    [
                      if (a.stageLabel != null) a.stageLabel!,
                      if (a.subtitle != null) a.subtitle!,
                      'ID ${a.id}',
                    ].join(' · '),
                  ),
                  trailing: a.isActive
                      ? const Icon(Icons.check_circle, color: AppColors.tertiary)
                      : null,
                  onTap: a.isActive
                      ? () => Navigator.pop(ctx)
                      : () async {
                          await ref
                              .read(activeUserIdProvider.notifier)
                              .switchTo(a.id);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                ),
              const SizedBox(height: SpacingTokens.sm),
              FilledButton.icon(
                key: const Key('account_add'),
                onPressed: () async {
                  final name = await _promptNickname(ctx);
                  if (name == null || name.isEmpty) return;
                  await ref
                      .read(activeUserIdProvider.notifier)
                      .createAccount(nickname: name);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryDeep,
                ),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('新建账号'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _promptNickname(BuildContext context) async {
    final controller = TextEditingController(text: '妈妈');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建本地账号'),
        content: TextField(
          key: const Key('new_account_nickname'),
          controller: controller,
          maxLength: 20,
          decoration: const InputDecoration(labelText: AppCopy.nicknameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppCopy.privacyClose),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final exporter = ref.read(dataExporterProvider);
    await exporter(AppCopy.emptyExportJson);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已准备导出数据')),
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppCopy.deleteData),
        content: const Text(AppCopy.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppCopy.privacyClose),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppCopy.deleteData),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(privacyStoreProvider).setAccepted(false);
      ref.invalidate(privacyAcceptedProvider);
      try {
        final uid =
            await ref.read(userProfileRepositoryProvider).getActiveUserId();
        await ref.read(conversationRepositoryProvider).clearAllMessages();
        await ref.read(summaryWriterProvider).clearSummaries(userId: uid);
      } catch (e) {
        debugPrint('wipe on delete failed: $e');
      }
      ref.invalidate(conversationListProvider);
    }
  }

  Future<void> _clearChatHistory(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppCopy.clearChatHistory),
        content: const Text(AppCopy.clearChatHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppCopy.privacyClose),
          ),
          TextButton(
            key: const Key('confirm_clear_chat'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppCopy.clearChatHistory),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(conversationRepositoryProvider).clearAllMessages();
      ref.invalidate(conversationListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppCopy.clearChatHistoryDone)),
        );
      }
    }
  }

  Future<void> _clearSummaries(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppCopy.clearSummaries),
        content: const Text(AppCopy.clearSummariesConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppCopy.privacyClose),
          ),
          TextButton(
            key: const Key('confirm_clear_summaries'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppCopy.clearSummaries),
          ),
        ],
      ),
    );
    if (ok == true) {
      final uid =
          await ref.read(userProfileRepositoryProvider).getActiveUserId();
      await ref.read(summaryWriterProvider).clearSummaries(userId: uid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppCopy.clearSummariesDone)),
        );
      }
    }
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.snapshot,
    required this.onSwitchAccount,
  });

  final UserProfileSnapshot snapshot;
  final VoidCallback onSwitchAccount;

  @override
  Widget build(BuildContext context) {
    final age = snapshot.ageYears;
    final agePart = age == null ? '' : ' · $age岁';
    return GlassContainer(
      fill: GlassFill.heavy,
      borderRadius: RadiusTokens.borderXl,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.glassRoseSoft,
            child: Text(
              _initial(snapshot.displayName),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryDeep,
                  ),
            ),
          ),
          const SizedBox(width: SpacingTokens.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${snapshot.displayName}$agePart',
                  key: const Key('profile_hero_name'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  EffectiveJourney.fromSnapshot(snapshot).primaryLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('profile_switch_account'),
            tooltip: '切换账号',
            onPressed: onSwitchAccount,
            icon: const Icon(Icons.switch_account_outlined),
          ),
        ],
      ),
    );
  }
}

class _ProfilePinnedBar extends StatelessWidget {
  const _ProfilePinnedBar({
    required this.snapshot,
    required this.onSwitchAccount,
  });

  final UserProfileSnapshot snapshot;
  final VoidCallback onSwitchAccount;

  @override
  Widget build(BuildContext context) {
    final age = snapshot.ageYears;
    final agePart = age == null ? '' : ' · $age岁';
    return GlassContainer(
      key: const Key('profile_pinned_bar'),
      fill: GlassFill.heavy,
      borderRadius: RadiusTokens.borderLg,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.glassRoseSoft,
            child: Text(
              _initial(snapshot.displayName),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryDeep,
                  ),
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              '我的 · ${snapshot.displayName}$agePart',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          IconButton(
            key: const Key('profile_switch_account_pinned'),
            tooltip: '切换账号',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: onSwitchAccount,
            icon: const Icon(Icons.switch_account_outlined, size: 20),
          ),
        ],
      ),
    );
  }
}

class _TodayStrip extends StatelessWidget {
  const _TodayStrip({required this.snapshotAsync});

  final AsyncValue<UserProfileSnapshot> snapshotAsync;

  @override
  Widget build(BuildContext context) {
    return snapshotAsync.maybeWhen(
      data: (snap) {
        final c = snap.rich.todayCheckIn;
        final journey = EffectiveJourney.fromSnapshot(snap);
        final chips = <String>[
          if (c.waterMl != null) '水 ${c.waterMl!.round()}ml',
          if (c.weightKg != null) '体重 ${c.weightKg}kg',
          if (c.sleepHours != null) '睡 ${c.sleepHours}h',
          if (c.steps != null) '步 ${c.steps}',
          if (c.mood != null && c.mood!.isNotEmpty) '心情 ${c.mood}',
          if (journey.showBabyMovement && c.babyMovementCount != null)
            '胎动 ${c.babyMovementCount}',
          if (journey.showPrenatalVitaminNudge &&
              c.prenatalVitaminTaken == true)
            '已服孕维',
        ];
        if (chips.isEmpty) {
          return GlassContainer(
            fill: GlassFill.medium,
            borderRadius: RadiusTokens.borderLg,
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Text(
              '今日打卡：还没有记录，可在生活方式里填写，或对小暖说「我吃了叶酸」',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        return GlassContainer(
          fill: GlassFill.medium,
          borderRadius: RadiusTokens.borderLg,
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              Text('今日', style: Theme.of(context).textTheme.labelLarge),
              for (final chip in chips)
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.glassRoseSoft,
                    borderRadius: RadiusTokens.borderPill,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.sm,
                      vertical: SpacingTokens.xs,
                    ),
                    child: Text(chip),
                  ),
                ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _MeTile extends StatelessWidget {
  const _MeTile({
    required this.tileKey,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final Key tileKey;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: tileKey,
      leading: CircleAvatar(
        backgroundColor: AppColors.glassRoseSoft,
        child: Icon(icon, color: AppColors.primaryDeep, size: 20),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

String _initial(String name) {
  if (name.isEmpty) return '?';
  return String.fromCharCodes(name.runes.take(1));
}
