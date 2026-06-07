import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../data/providers/gallery_providers.dart';

/// Live drafts list — reads from Hive via draftsStoreProvider.
/// Every variant generated in Content Studio auto-saves here.
class DraftHistory extends ConsumerWidget {
  const DraftHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(draftsStoreProvider);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Your drafts',
            subtitle: drafts.isEmpty
                ? 'Generate something — it auto-saves here'
                : '${drafts.length} saved · auto-persisted across sessions',
            trailing: drafts.isEmpty
                ? null
                : TextButton.icon(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Clear all drafts?'),
                          content: const Text(
                              'This wipes every saved variant. Cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        ref.read(draftsStoreProvider.notifier).clear();
                      }
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Clear all'),
                  ),
          ),
          if (drafts.isEmpty)
            _EmptyState()
          else
            for (final d in drafts.take(20))
              _DraftRow(
                draft: d,
                onStar: () =>
                    ref.read(draftsStoreProvider.notifier).toggleStar(d.id),
                onDelete: () =>
                    ref.read(draftsStoreProvider.notifier).remove(d.id),
              ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            AppSpacing.vGapMd,
            Text(
              'No saved drafts yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AppSpacing.vGapXs,
            Text(
              'Every variant you generate above auto-saves here.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftRow extends StatelessWidget {
  const _DraftRow({
    required this.draft,
    required this.onStar,
    required this.onDelete,
  });
  final SavedDraft draft;
  final VoidCallback onStar;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: AppColors.mythrixViolet.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border:
                  Border.all(color: AppColors.mythrixViolet.withValues(alpha: 0.25)),
            ),
            child: const Icon(Icons.description_rounded,
                size: 16, color: AppColors.mythrixViolet),
          ),
          AppSpacing.hGapSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        draft.title,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (draft.starred) ...[
                      AppSpacing.hGapXs,
                      const Icon(Icons.star_rounded,
                          size: 14, color: AppColors.mythrixAmber),
                    ],
                  ],
                ),
                Text(
                  draft.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                ),
              ],
            ),
          ),
          AppSpacing.hGapMd,
          StatusPill(label: draft.type, tone: PillTone.neutral, dense: true),
          AppSpacing.hGapSm,
          StatusPill(label: draft.tone, tone: PillTone.brand, dense: true),
          AppSpacing.hGapMd,
          SizedBox(
            width: 70,
            child: Text(
              Fmt.relative(draft.createdAt),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
              textAlign: TextAlign.right,
            ),
          ),
          IconButton(
            onPressed: onStar,
            tooltip: draft.starred ? 'Unstar' : 'Star',
            icon: Icon(
              draft.starred ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 16,
              color: draft.starred ? AppColors.mythrixAmber : null,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline_rounded, size: 16),
          ),
        ],
      ),
    );
  }
}
