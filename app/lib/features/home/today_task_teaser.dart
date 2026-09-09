import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_copy.dart';
import '../../providers.dart';
import '../../tasks/task_cards.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/glass/glass_container.dart';

/// Home「今日照护」task list (AC-10-F01 / F02).
class TodayTaskTeaser extends ConsumerWidget {
  const TodayTaskTeaser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(todayTaskCardsProvider);
    return async.when(
      loading: () => Text(
        '…',
        key: const Key('today_tasks_loading'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
      ),
      error: (_, __) => Text(
        AppCopy.noTasksToday,
        key: const Key('today_tasks'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
      ),
      data: (tasks) {
        if (tasks.isEmpty) {
          return Text(
            AppCopy.noTasksToday,
            key: const Key('today_tasks'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          );
        }
        return Column(
          key: const Key('today_tasks'),
          children: [
            for (final task in tasks)
              _TaskRow(
                task: task,
                onToggle: () async {
                  final service =
                      await ref.read(taskCardServiceProvider.future);
                  await service.toggle(task.id);
                  ref.invalidate(todayTaskCardsProvider);
                },
              ),
          ],
        );
      },
    );
  }
}

/// Glass section wrapping [TodayTaskTeaser] for the Home dashboard.
class TodayCareModule extends ConsumerWidget {
  const TodayCareModule({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      key: const Key('today_care_module'),
      fill: GlassFill.roseSoft,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('今日照护', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            '温和习惯提醒，不构成医疗建议',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          const TodayTaskTeaser(),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.onToggle});

  final TaskCardView task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      key: Key('task_${task.id}'),
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      value: task.isDone,
      onChanged: (_) => onToggle(),
      title: Text(
        task.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              decoration: task.isDone ? TextDecoration.lineThrough : null,
            ),
      ),
      subtitle: task.body.isEmpty
          ? null
          : Text(
              task.body,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
    );
  }
}
