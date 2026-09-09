import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../llm/llm_model_catalog.dart';
import '../../providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/glass/glass_container.dart';

/// Slim model dropdown under the chat glass app bar.
class LlmModelPickerBar extends ConsumerWidget {
  const LlmModelPickerBar({super.key});

  static const double height = 44;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(llmModelCatalogProvider);
    final selectedId = ref.watch(selectedLlmModelIdProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.pageMargin,
        0,
        SpacingTokens.pageMargin,
        SpacingTokens.sm,
      ),
      child: GlassContainer(
        fill: GlassFill.light,
        borderRadius: RadiusTokens.borderMd,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
        child: catalogAsync.when(
          loading: () => Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '模型加载中…',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ),
          error: (_, __) => Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '模型列表不可用',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ),
          data: (catalog) {
            final options = catalog.enabledModels;
            if (options.isEmpty) {
              return const SizedBox.shrink();
            }
            final effective = catalog.resolve(selectedId);
            return Row(
              children: [
                Text(
                  '模型',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      key: const Key('llm_model_picker'),
                      isExpanded: true,
                      value: effective.id,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.onSurfaceVariant,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface,
                          ),
                      dropdownColor: AppColors.neutral,
                      items: [
                        for (final m in options)
                          DropdownMenuItem<String>(
                            value: m.id,
                            child: Text(_label(m)),
                          ),
                      ],
                      onChanged: (id) {
                        if (id == null) return;
                        ref
                            .read(selectedLlmModelIdProvider.notifier)
                            .select(id);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _label(LlmModelOption m) {
    if (m.offline) return '${m.displayName}（离线）';
    return m.displayName;
  }
}
