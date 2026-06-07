import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_pill.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/campaign.dart';
import '../../data/providers/campaigns_providers.dart';
import '../../data/providers/chat_providers.dart';
import '../../data/providers/crm_deals_providers.dart';
import '../../data/providers/email_campaigns_providers.dart';
import '../../data/providers/gallery_providers.dart';
import '../../data/providers/scheduled_posts_providers.dart';
import 'export_service.dart';

/// Unified Library — every persisted artifact across the app in one place.
/// Tabs: Drafts · Images · Posts · Campaigns · Chat
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 7, vsync: this);
  String _query = '';

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drafts = ref.watch(draftsStoreProvider);
    final images = ref.watch(galleryProvider);
    final posts = ref.watch(scheduledPostsProvider);
    final campaigns = ref.watch(campaignsStoreProvider);
    final chats = ref.watch(chatMessagesProvider);
    final emails = ref.watch(emailCampaignsProvider);
    final deals = ref.watch(crmDealsProvider);

    final totalCount = drafts.length +
        images.length +
        posts.length +
        campaigns.length +
        chats.length +
        emails.length +
        deals.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Library',
                        style: Theme.of(context).textTheme.headlineLarge),
                    AppSpacing.vGapXs,
                    Text(
                      'Everything Mythrix has created for you — $totalCount artifacts, auto-saved across sessions.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.65),
                          ),
                    ),
                  ],
                ),
              ),
              if (totalCount > 0)
                GradientButton(
                  label: 'Export all',
                  icon: Icons.file_download_outlined,
                  onPressed: () async {
                    final summary =
                        await ExportService.copyJsonToClipboard(ref);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '📋 Copied to clipboard: $summary. Paste into any text editor and save as .json'),
                          duration: const Duration(seconds: 6),
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
          AppSpacing.vGapXl,
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 18),
                AppSpacing.hGapSm,
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search drafts, prompts, posts, campaigns…',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGapMd,
          TabBar(
            controller: _tab,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Drafts (${drafts.length})'),
              Tab(text: 'Images (${images.length})'),
              Tab(text: 'Scheduled (${posts.length})'),
              Tab(text: 'Campaigns (${campaigns.length})'),
              Tab(text: 'Emails (${emails.length})'),
              Tab(text: 'Deals (${deals.length})'),
              Tab(text: 'Chat (${chats.length})'),
            ],
          ),
          const Divider(height: 1),
          SizedBox(
            height: 700,
            child: TabBarView(
              controller: _tab,
              children: [
                _DraftsTab(query: _query),
                _ImagesTab(query: _query),
                _PostsTab(query: _query),
                _CampaignsTab(query: _query),
                _EmailsTab(query: _query),
                _DealsTab(query: _query),
                _ChatTab(query: _query),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Tabs ----------------

class _DraftsTab extends ConsumerWidget {
  const _DraftsTab({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(draftsStoreProvider);
    final filtered = query.isEmpty
        ? all
        : all
            .where((d) =>
                d.title.toLowerCase().contains(query) ||
                d.body.toLowerCase().contains(query))
            .toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.description_outlined,
        title: 'No drafts yet',
        message: 'Generate something in Content Studio — it auto-saves here.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final d = filtered[i];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(d.title,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (d.starred)
                    const Icon(Icons.star_rounded,
                        size: 14, color: AppColors.mythrixAmber),
                  AppSpacing.hGapSm,
                  StatusPill(label: d.type, tone: PillTone.neutral, dense: true),
                  AppSpacing.hGapXs,
                  StatusPill(label: d.tone, tone: PillTone.brand, dense: true),
                ],
              ),
              AppSpacing.vGapXs,
              Text(
                d.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.65),
                      height: 1.5,
                    ),
              ),
              AppSpacing.vGapSm,
              Row(
                children: [
                  Text(
                    Fmt.relative(d.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        ref.read(draftsStoreProvider.notifier).toggleStar(d.id),
                    icon: Icon(
                      d.starred
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 18,
                      color: d.starred ? AppColors.mythrixAmber : null,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.read(draftsStoreProvider.notifier).remove(d.id),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImagesTab extends ConsumerWidget {
  const _ImagesTab({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(galleryProvider);
    final filtered = query.isEmpty
        ? all
        : all.where((g) => g.prompt.toLowerCase().contains(query)).toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.image_outlined,
        title: 'No images yet',
        message: 'Generate something in Creative Studio — images persist here.',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.85,
        ),
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final g = filtered[i];
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
                CachedNetworkImage(
                  imageUrl: g.url,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image_rounded,
                        color: Colors.white54),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.75),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          g.prompt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${g.style} · ${Fmt.relative(g.createdAt)}',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: Row(
                    children: [
                      _MiniIcon(
                        icon: g.starred
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: g.starred ? AppColors.mythrixAmber : Colors.white,
                        onTap: () => ref
                            .read(galleryProvider.notifier)
                            .toggleStar(g.id),
                      ),
                      const SizedBox(width: 4),
                      _MiniIcon(
                        icon: Icons.delete_outline_rounded,
                        color: Colors.white,
                        onTap: () =>
                            ref.read(galleryProvider.notifier).remove(g.id),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  const _MiniIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 14),
        ),
      ),
    );
  }
}

class _PostsTab extends ConsumerWidget {
  const _PostsTab({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(scheduledPostsProvider);
    final filtered = query.isEmpty
        ? all
        : all.where((p) => p.body.toLowerCase().contains(query)).toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.event_outlined,
        title: 'No scheduled posts',
        message:
            'Schedule something in Social Scheduler — it persists across sessions.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final p = filtered[i];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.mythrixViolet, AppColors.mythrixCyan],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.send_rounded, color: Colors.white),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(
                      '${p.channels.map((c) => c.displayName).join(", ")} · ${Fmt.relative(p.scheduledFor)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55),
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(scheduledPostsProvider.notifier).remove(p.id),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CampaignsTab extends ConsumerWidget {
  const _CampaignsTab({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(campaignsStoreProvider);
    final filtered = query.isEmpty
        ? all
        : all.where((c) => c.name.toLowerCase().contains(query)).toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.campaign_outlined,
        title: 'No campaigns launched yet',
        message:
            'Use "Launch with MYTHRIX" in Ads Manager — it persists across sessions.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final c = filtered[i];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.rocket_launch_rounded,
                      color: AppColors.mythrixViolet),
                  AppSpacing.hGapSm,
                  Expanded(
                    child: Text(c.name,
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  StatusPill(
                    label: c.status.name,
                    tone: c.status == CampaignStatus.active
                        ? PillTone.success
                        : PillTone.warning,
                    dense: true,
                  ),
                ],
              ),
              AppSpacing.vGapXs,
              Text(
                '${c.networks.map((n) => n.displayName).join(", ")} · ${c.objective.displayName} · \$${c.dailyBudget.toStringAsFixed(0)}/day',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
              AppSpacing.vGapSm,
              Row(
                children: [
                  Text(
                    'Launched ${Fmt.relative(c.launchedAt)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        ref.read(campaignsStoreProvider.notifier).toggleStatus(c.id),
                    icon: Icon(
                      c.status == CampaignStatus.active
                          ? Icons.pause_circle_outline_rounded
                          : Icons.play_circle_outline_rounded,
                      size: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.read(campaignsStoreProvider.notifier).remove(c.id),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatTab extends ConsumerWidget {
  const _ChatTab({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(chatMessagesProvider);
    final filtered = query.isEmpty
        ? all
        : all.where((m) => m.text.toLowerCase().contains(query)).toList();

    if (filtered.length <= 1) {
      return const EmptyState(
        icon: Icons.forum_outlined,
        title: 'Chat is empty',
        message:
            'Open the chat orb (bottom-right) and ask Mythrix anything — every message saves here.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final m = filtered[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusPill(
                      label: m.role.name.toUpperCase(),
                      tone: m.role.name == 'user'
                          ? PillTone.brand
                          : PillTone.neutral,
                      dense: true,
                    ),
                    const Spacer(),
                    Text(
                      Fmt.relative(m.sentAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ),
                AppSpacing.vGapXs,
                Text(m.text,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmailsTab extends ConsumerWidget {
  const _EmailsTab({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(emailCampaignsProvider);
    final filtered = query.isEmpty
        ? all
        : all
            .where((e) =>
                e.subject.toLowerCase().contains(query) ||
                e.body.toLowerCase().contains(query))
            .toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.mail_outline_rounded,
        title: 'No email campaigns yet',
        message: 'Click "New campaign" in Email Marketing to save one.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final e = filtered[i];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    AppColors.mythrixViolet,
                    AppColors.mythrixCyan,
                  ]),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.alternate_email_rounded, color: Colors.white),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.subject,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (e.preview.isNotEmpty)
                      Text(
                        e.preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.55),
                            ),
                      ),
                    Text(
                      '${e.recipientCount} recipients · ${Fmt.relative(e.createdAt)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(emailCampaignsProvider.notifier).remove(e.id),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DealsTab extends ConsumerWidget {
  const _DealsTab({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(crmDealsProvider);
    final filtered = query.isEmpty
        ? all
        : all
            .where((d) => d.companyName.toLowerCase().contains(query))
            .toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.business_outlined,
        title: 'No deals yet',
        message:
            'Click "Add deal" in CRM to create one — it appears here with its stage.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final d = filtered[i];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.mythrixViolet.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.business_rounded,
                    color: AppColors.mythrixViolet),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.companyName,
                        style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      '${d.valueFormatted} · AI score ${d.aiScore} · ${Fmt.relative(d.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55),
                          ),
                    ),
                  ],
                ),
              ),
              StatusPill(label: d.stage.label, tone: PillTone.brand, dense: true),
              IconButton(
                onPressed: () =>
                    ref.read(crmDealsProvider.notifier).remove(d.id),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
              ),
            ],
          ),
        );
      },
    );
  }
}
