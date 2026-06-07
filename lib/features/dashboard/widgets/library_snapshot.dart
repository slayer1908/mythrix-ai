import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/providers/campaigns_providers.dart';
import '../../../data/providers/chat_providers.dart';
import '../../../data/providers/gallery_providers.dart';
import '../../../data/providers/scheduled_posts_providers.dart';

/// At-a-glance counts of every artifact persisted across the app.
/// Tap any tile to jump to the Library with that tab active.
class LibrarySnapshot extends ConsumerWidget {
  const LibrarySnapshot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftCount = ref.watch(draftsStoreProvider).length;
    final imageCount = ref.watch(galleryProvider).length;
    final postCount = ref.watch(scheduledPostsProvider).length;
    final campaignCount = ref.watch(campaignsStoreProvider).length;
    final chatCount = ref.watch(chatMessagesProvider).length;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Your Mythrix library',
            subtitle: 'Everything Mythrix has saved for you — tap to explore',
            icon: Icons.collections_bookmark_rounded,
            trailing: TextButton.icon(
              onPressed: () => context.go(AppRoutes.library),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Open Library'),
            ),
          ),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth >= 720 ? 5 : (c.maxWidth >= 480 ? 3 : 2);
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.3,
                children: [
                  _Tile(
                    icon: Icons.description_rounded,
                    label: 'Drafts',
                    count: draftCount,
                    color: AppColors.mythrixViolet,
                    onTap: () => context.go(AppRoutes.library),
                  ),
                  _Tile(
                    icon: Icons.image_rounded,
                    label: 'Images',
                    count: imageCount,
                    color: AppColors.mythrixMagenta,
                    onTap: () => context.go(AppRoutes.library),
                  ),
                  _Tile(
                    icon: Icons.event_rounded,
                    label: 'Scheduled',
                    count: postCount,
                    color: AppColors.mythrixCyan,
                    onTap: () => context.go(AppRoutes.library),
                  ),
                  _Tile(
                    icon: Icons.rocket_launch_rounded,
                    label: 'Campaigns',
                    count: campaignCount,
                    color: AppColors.mythrixLime,
                    onTap: () => context.go(AppRoutes.library),
                  ),
                  _Tile(
                    icon: Icons.forum_rounded,
                    label: 'Chat',
                    count: chatCount,
                    color: AppColors.mythrixAmber,
                    onTap: () => context.go(AppRoutes.library),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatefulWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: _hover
                ? widget.color.withValues(alpha: 0.14)
                : Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: _hover
                  ? widget.color.withValues(alpha: 0.4)
                  : Theme.of(context).colorScheme.outline,
            ),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.22),
                      blurRadius: 20,
                      spreadRadius: -4,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.color.withValues(alpha: 0.25),
                      widget.color.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: widget.color.withValues(alpha: 0.3)),
                ),
                child: Icon(widget.icon, color: widget.color, size: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.count}',
                    style: AppTypography.kpiNumber(
                      size: 28,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
