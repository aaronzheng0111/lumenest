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
    return AtmosphereBackground(
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _EmptyConversations(),
        data: (items) {
          if (items.isEmpty) return const _EmptyConversations();
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              SpacingTokens.pageMargin,
              MediaQuery.paddingOf(context).top + SpacingTokens.lg,
              SpacingTokens.pageMargin,
              GlassTabBar.height + SpacingTokens.xl,
            ),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: SpacingTokens.sm),
            itemBuilder: (context, index) {
              final item = items[index];
              return GlassContainer(
                fill: GlassFill.medium,
                borderRadius: RadiusTokens.borderXl,
                child: ListTile(
                  key: Key('conversation_${item.id}'),
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(item.role.avatarAsset),
                  ),
                  title: Text(item.role.displayName),
                  subtitle: Text(
                    item.preview ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/chat?role=${item.role.wireId}',
                    );
                  },
                ),
              );
            },
          );
        },
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
