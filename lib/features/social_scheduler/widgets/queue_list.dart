import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/snack.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../data/models/scheduled_post.dart';

class QueueList extends StatelessWidget {
  const QueueList({super.key, required this.posts});
  final List<ScheduledPost> posts;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Scheduled queue',
            subtitle: '${posts.length} upcoming',
            trailing: Row(
              children: [
                Builder(builder: (ctx) => OutlinedButton.icon(
                  onPressed: () => Snack.info(ctx, 'Filtering by channel/status arrives with the queue rewrite.'),
                  icon: const Icon(Icons.filter_list_rounded, size: 14),
                  label: const Text('Filter'),
                )),
                AppSpacing.hGapSm,
                Builder(builder: (ctx) => OutlinedButton.icon(
                  onPressed: () => Snack.info(ctx, 'Calendar view ships alongside drag-and-drop rescheduling.'),
                  icon: const Icon(Icons.calendar_view_month_rounded, size: 14),
                  label: const Text('Calendar'),
                )),
              ],
            ),
          ),
          for (final p in posts) _Row(post: p),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.post});
  final ScheduledPost post;

  IconData _iconFor(SocialChannel c) {
    return switch (c) {
      SocialChannel.instagram => Icons.camera_alt_rounded,
      SocialChannel.facebook => Icons.facebook_rounded,
      SocialChannel.twitter => Icons.tag_rounded,
      SocialChannel.linkedin => Icons.work_outline_rounded,
      SocialChannel.tiktok => Icons.music_note_rounded,
      SocialChannel.youtube => Icons.play_arrow_rounded,
      SocialChannel.pinterest => Icons.push_pin_rounded,
      SocialChannel.threads => Icons.alternate_email_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.mythrixViolet, AppColors.mythrixCyan]),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.image_rounded, color: Colors.white),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(post.title,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (post.aiGenerated)
                      const StatusPill(label: 'AI', tone: PillTone.brand, dense: true),
                  ],
                ),
                AppSpacing.vGapXs,
                Text(
                  post.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
                AppSpacing.vGapXs,
                Row(
                  children: [
                    for (final c in post.channels.take(4))
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(_iconFor(c),
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
                      ),
                    AppSpacing.hGapSm,
                    Text(
                      Fmt.dateTime(post.scheduledFor),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Builder(builder: (ctx) => IconButton(
            onPressed: () => Snack.info(ctx, 'Inline post editing lands with the composer rewrite — for now, delete and recreate.'),
            icon: const Icon(Icons.edit_outlined, size: 18),
          )),
          Builder(builder: (ctx) => IconButton(
            onPressed: () => Snack.info(ctx, 'Per-post actions (duplicate, reschedule, post now) shipping next.'),
            icon: const Icon(Icons.more_horiz_rounded, size: 18),
          )),
        ],
      ),
    );
  }
}
