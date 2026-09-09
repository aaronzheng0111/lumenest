import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_copy.dart';
import '../../providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_tab_bar.dart';
import 'me_profile_form.dart';
import 'privacy_sheet.dart';

class MeInfoPage extends ConsumerWidget {
  const MeInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AtmosphereBackground(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          SpacingTokens.pageMargin,
          MediaQuery.paddingOf(context).top + SpacingTokens.lg,
          SpacingTokens.pageMargin,
          MediaQuery.paddingOf(context).bottom +
              GlassTabBar.height +
              SpacingTokens.xl,
        ),
        children: [
          Text('我的', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: SpacingTokens.lg),
          GlassContainer(
            fill: GlassFill.heavy,
            borderRadius: RadiusTokens.borderXl,
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
            child: Column(
              children: [
                _MeTile(
                  tileKey: const Key('me_edit_profile'),
                  icon: Icons.edit_outlined,
                  title: AppCopy.editProfile,
                  onTap: () async {
                    final saved = await Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => const MeProfileFormPage(),
                      ),
                    );
                    if (saved == true) {
                      ref.invalidate(userProfileSnapshotProvider);
                    }
                  },
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
    );
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
        await ref.read(conversationRepositoryProvider).clearAllMessages();
        await ref.read(summaryWriterProvider).clearSummaries(userId: 1);
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
      await ref.read(summaryWriterProvider).clearSummaries(userId: 1);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppCopy.clearSummariesDone)),
        );
      }
    }
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
