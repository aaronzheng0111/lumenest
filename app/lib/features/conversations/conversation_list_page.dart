import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_copy.dart';
import '../../domain/agent_role.dart';
import '../../providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_tab_bar.dart';

class ConversationListPage extends ConsumerWidget {
  const ConversationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(conversationListProvider);
    final groupEnabled = ref.watch(groupConsultEnabledProvider);
    return AtmosphereBackground(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              SpacingTokens.pageMargin,
              MediaQuery.paddingOf(context).top + SpacingTokens.lg,
              SpacingTokens.pageMargin,
              SpacingTokens.sm,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                key: const Key('group_consult_btn'),
                onPressed: () {
                  if (!groupEnabled) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppCopy.groupConsultNeedsUpgrade),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).pushNamed('/chat/group');
                },
                icon: const Icon(Icons.groups_rounded),
                label: const Text(AppCopy.groupConsult),
              ),
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const _EmptyConversations(),
              data: (items) {
                if (items.isEmpty) return const _EmptyConversations();
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    SpacingTokens.pageMargin,
                    0,
                    SpacingTokens.pageMargin,
                    GlassTabBar.height + SpacingTokens.xl,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: SpacingTokens.sm),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final title = item.isGroup
                        ? AppCopy.groupConsult
                        : item.role.displayName;
                    return GlassContainer(
                      fill: GlassFill.medium,
                      borderRadius: RadiusTokens.borderXl,
                      child: ListTile(
                        key: Key('conversation_${item.id}'),
                        leading: CircleAvatar(
                          backgroundImage: item.isGroup
                              ? null
                              : AssetImage(item.role.avatarAsset),
                          child: item.isGroup
                              ? const Icon(Icons.groups_rounded)
                              : null,
                        ),
                        title: Text(title),
                        subtitle: Text(
                          item.preview ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          if (item.isGroup) {
                            Navigator.of(context).pushNamed('/chat/group');
                          } else {
                            Navigator.of(context).pushNamed(
                              '/chat?role=${item.role.wireId}',
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.pageMargin,
          SpacingTokens.xl,
          SpacingTokens.pageMargin,
          GlassTabBar.height + SpacingTokens.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/illustrations/empty-chat.png',
              width: 160,
              height: 160,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.chat_bubble_outline,
                size: 72,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              AppCopy.emptyConversations,
              key: const Key('empty_conversations'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
