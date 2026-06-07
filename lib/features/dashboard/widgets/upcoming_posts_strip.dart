import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../data/models/scheduled_post.dart';
import '../../../data/providers/workspace_providers.dart';

class UpcomingPostsStrip extends ConsumerWidget {
  const UpcomingPostsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(upcomingPostsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Up next on the calendar',
          subtitle: 'AI-scheduled and human-approved posts',
          trailing: TextButton(onPressed: () => context.go('/app/social'), child: const Text('Open scheduler')),
        ),
        async.when(
          data: (posts) => SizedBox(
            height: 196,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: posts.length,
              separatorBuilder: (_, __) => AppSpacing.hGapMd,
              itemBuilder: (_, i) => SizedBox(width: 320, child: _PostCard(post: posts[i])),
            ),
          ),
          error: (e, _) => Text('Could not load: $e'),
          loading: () => const SizedBox(height: 160, child: Center(child: MythrixLoader())),
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});
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
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      hoverable: true,
      onTap: () => context.go('/app/social'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(
                label: Fmt.relative(post.scheduledFor),
                tone: PillTone.brand,
                dense: true,
              ),
              const Spacer(),
              if (post.aiGenerated)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 10, color: Colors.white),
                      SizedBox(width: 4),
                      Text('AI', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ),
          AppSpacing.vGapSm,
          Text(
            post.title,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.vGapXs,
          Expanded(
            child: Text(
              post.body,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppSpacing.vGapSm,
          Row(
            children: [
              for (final c in post.channels.take(4))
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: Icon(_iconFor(c), size: 12),
                  ),
                ),
              const Spacer(),
              Text(
                Fmt.dateTime(post.scheduledFor),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
