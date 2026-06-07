import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/integration.dart';
import '../../data/providers/brand_profile_providers.dart';
import '../../data/providers/integrations_providers.dart';

/// One screen, configurable by network. Drops the user into a dedicated
/// management view for Google Ads, Meta, TikTok, LinkedIn, etc. — each with
/// its own quick stats, campaign list, ad-network-specific actions, and a
/// "Connect" CTA when the network isn't linked yet.
class NetworkAdsScreen extends ConsumerWidget {
  const NetworkAdsScreen({super.key, required this.networkId});
  final String networkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final integrations = ref.watch(integrationsProvider);
    final brand = ref.watch(brandProfileProvider);
    final network = integrations.firstWhere(
      (i) => i.id == networkId,
      orElse: () => integrations.first,
    );
    final isConnected = network.status == IntegrationStatus.connected;
    final brandColor = brand?.accentColor ?? AppColors.mythrixViolet;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(network: network, isConnected: isConnected, brandColor: brandColor),
          AppSpacing.vGapXl,
          if (!isConnected)
            _ConnectCTA(network: network)
          else ...[
            _QuickStats(network: network),
            AppSpacing.vGapXl,
            _CampaignSummary(network: network),
            AppSpacing.vGapXl,
            _NetworkActions(network: network),
            AppSpacing.vGapXl,
          ],
          _FeatureGrid(network: network),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.network, required this.isConnected, required this.brandColor});
  final Integration network;
  final bool isConnected;
  final Color brandColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: network.color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(network.category.icon, color: network.color, size: 28),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(network.name, style: Theme.of(context).textTheme.headlineLarge),
                  AppSpacing.hGapSm,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isConnected
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      isConnected ? '● Live' : '○ Not connected',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isConnected ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.vGapXs,
              Text(network.tagline,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                      )),
            ],
          ),
        ),
        if (isConnected) ...[
          GradientButton(
            label: 'New campaign',
            icon: Icons.add_rounded,
            onPressed: () => Snack.info(context, 'Launching ${network.name} campaign wizard…'),
          ),
        ],
      ],
    );
  }
}

class _ConnectCTA extends ConsumerWidget {
  const _ConnectCTA({required this.network});
  final Integration network;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: network.color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.link_rounded, color: network.color, size: 32),
          ),
          AppSpacing.vGapMd,
          Text('Connect ${network.name}', style: Theme.of(context).textTheme.titleLarge),
          AppSpacing.vGapXs,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Text(
              'Mythrix needs read + write access to your ${network.name} account to launch campaigns, fetch performance, and run automation rules.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ),
          AppSpacing.vGapLg,
          GradientButton(
            label: 'Connect with OAuth',
            icon: Icons.lock_rounded,
            onPressed: () {
              ref.read(integrationsProvider.notifier).toggleConnection(network.id);
              Snack.success(context,
                  '✓ ${network.name} connected. Real OAuth wires up in ${network.phase}.');
            },
          ),
          AppSpacing.vGapSm,
          Text(
            'Phase: ${network.phase}',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.5,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.network});
  final Integration network;

  @override
  Widget build(BuildContext context) {
    final stats = _statsFor(network.id);
    return Row(
      children: [
        for (final s in stats) ...[
          Expanded(child: _StatTile(label: s.$1, value: s.$2, accent: network.color)),
          if (s != stats.last) AppSpacing.hGapMd,
        ],
      ],
    );
  }

  List<(String, String)> _statsFor(String id) {
    // Per-network mocked headline metrics — replaced by real API in Phase 4.
    switch (id) {
      case 'google-ads':
        return const [
          ('Spend (30d)', '\$48,210'),
          ('Conversions', '3,128'),
          ('ROAS', '4.52×'),
          ('Quality Score', '8.4 / 10'),
        ];
      case 'google-lsa':
        return const [
          ('Spend (30d)', '\$3,240'),
          ('Booked leads', '184'),
          ('Avg cost / lead', '\$17.61'),
          ('Google Guaranteed', '✓ Active'),
        ];
      case 'meta-ads':
        return const [
          ('Spend (30d)', '\$22,180'),
          ('Conversions', '1,920'),
          ('ROAS', '3.78×'),
          ('Frequency', '2.4'),
        ];
      case 'tiktok-ads':
        return const [
          ('Spend (30d)', '\$8,470'),
          ('Conversions', '612'),
          ('VTR (6s)', '34.2%'),
          ('CPM', '\$5.20'),
        ];
      case 'linkedin-ads':
        return const [
          ('Spend (30d)', '\$11,940'),
          ('Conversions', '187'),
          ('CPC', '\$8.21'),
          ('Lead quality', '4.6 / 5'),
        ];
      case 'x-ads':
        return const [
          ('Spend (30d)', '\$2,180'),
          ('Engagements', '14,520'),
          ('CPE', '\$0.15'),
          ('Reply rate', '2.1%'),
        ];
      case 'microsoft-ads':
        return const [
          ('Spend (30d)', '\$5,640'),
          ('Conversions', '428'),
          ('CPA', '\$13.18'),
          ('Avg position', '#2.1'),
        ];
      case 'reddit-ads':
        return const [
          ('Spend (30d)', '\$1,820'),
          ('Conversions', '74'),
          ('CTR', '0.9%'),
          ('Comments', '1,247'),
        ];
      case 'pinterest-ads':
        return const [
          ('Spend (30d)', '\$3,910'),
          ('Conversions', '294'),
          ('Save rate', '4.8%'),
          ('CPM', '\$3.40'),
        ];
      case 'snapchat-ads':
        return const [
          ('Spend (30d)', '\$2,560'),
          ('Conversions', '156'),
          ('Swipe-up', '2.4%'),
          ('Avg watch', '4.2s'),
        ];
      case 'amazon-dsp':
        return const [
          ('Spend (30d)', '\$18,440'),
          ('ROAS', '5.12×'),
          ('Detail page views', '24,890'),
          ('Brand-new customers', '38%'),
        ];
      default:
        return const [];
    }
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.accent});
  final String label, value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              )),
          AppSpacing.vGapXs,
          Text(value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: accent,
              )),
        ],
      ),
    );
  }
}

class _CampaignSummary extends StatelessWidget {
  const _CampaignSummary({required this.network});
  final Integration network;

  @override
  Widget build(BuildContext context) {
    final rows = _rowsFor(network.id);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Active ${network.name} campaigns',
            subtitle: '${rows.length} live · synced 12 minutes ago',
            icon: Icons.campaign_rounded,
          ),
          for (final r in rows) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: network.color, shape: BoxShape.circle),
                  ),
                  AppSpacing.hGapSm,
                  Expanded(child: Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  Text('\$${r.$2}/d',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(width: 18),
                  Text(r.$3,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: r.$3.startsWith('+') ? AppColors.success : AppColors.danger)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<(String, int, String)> _rowsFor(String id) {
    switch (id) {
      case 'google-ads':
        return const [
          ('Brand search — Mythrix exact', 80, '+24%'),
          ('Performance Max — Q1 sales', 240, '+18%'),
          ('YouTube — brand consideration', 120, '+9%'),
          ('Demand Gen — discovery', 90, '-4%'),
        ];
      case 'meta-ads':
        return const [
          ('Advantage+ Shopping — winter', 320, '+31%'),
          ('Lookalike 1% — purchasers', 180, '+12%'),
          ('Retarget cart abandoners', 75, '+8%'),
          ('Reels prospecting', 110, '-2%'),
        ];
      case 'tiktok-ads':
        return const [
          ('Spark Ads — creator UGC', 95, '+44%'),
          ('TikTok Shop carousel', 140, '+22%'),
          ('Smart Performance — broad', 60, '+11%'),
        ];
      case 'linkedin-ads':
        return const [
          ('ABM — enterprise SaaS', 220, '+16%'),
          ('Sponsored Content — Q1', 180, '+7%'),
          ('Lead Gen Forms — webinar', 85, '+19%'),
        ];
      default:
        return [
          ('Brand awareness — Q1', 80, '+12%'),
          ('Retargeting — site visitors', 60, '+8%'),
        ];
    }
  }
}

class _NetworkActions extends StatelessWidget {
  const _NetworkActions({required this.network});
  final Integration network;

  @override
  Widget build(BuildContext context) {
    final actions = _actionsFor(network.id);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: '${network.name} quick actions',
            subtitle: 'One-tap workflows specific to this network',
            icon: Icons.bolt_rounded,
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final a in actions)
                Builder(builder: (ctx) => OutlinedButton.icon(
                  onPressed: () => Snack.info(ctx, '${a.$1} — wiring up.'),
                  icon: Icon(a.$2, size: 16, color: network.color),
                  label: Text(a.$1),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: network.color.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                )),
            ],
          ),
        ],
      ),
    );
  }

  List<(String, IconData)> _actionsFor(String id) {
    switch (id) {
      case 'google-ads':
        return const [
          ('Negative keyword sweep', Icons.block_rounded),
          ('Sync GA4 conversions', Icons.sync_rounded),
          ('PMax asset refresh', Icons.refresh_rounded),
          ('Bid strategy A/B test', Icons.science_rounded),
          ('Sitelink extensions', Icons.link_rounded),
        ];
      case 'meta-ads':
        return const [
          ('Generate 5 ad variations', Icons.auto_awesome_rounded),
          ('Refresh CAPI pixel', Icons.sync_rounded),
          ('Lookalike from top 1k buyers', Icons.people_rounded),
          ('Advantage+ campaign', Icons.bolt_rounded),
          ('Catalog feed audit', Icons.shopping_bag_outlined),
        ];
      case 'tiktok-ads':
        return const [
          ('Brief 3 creators', Icons.video_call_rounded),
          ('Sound-on hook test', Icons.music_note_rounded),
          ('Spark Ads from organic', Icons.flash_on_rounded),
          ('TikTok Shop sync', Icons.shopping_bag_outlined),
        ];
      case 'linkedin-ads':
        return const [
          ('Upload account list', Icons.upload_file_rounded),
          ('Document Ad PDF', Icons.picture_as_pdf_rounded),
          ('Lead Gen form preset', Icons.assignment_rounded),
          ('Conversation Ad sequence', Icons.chat_rounded),
        ];
      default:
        return const [
          ('Refresh insights', Icons.refresh_rounded),
          ('Duplicate top campaign', Icons.copy_rounded),
          ('Pause underperformers', Icons.pause_rounded),
        ];
    }
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.network});
  final Integration network;

  @override
  Widget build(BuildContext context) {
    if (network.features.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'What you get with ${network.name}',
          subtitle: 'Every native feature Mythrix exposes',
          icon: Icons.checklist_rounded,
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final f in network.features)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: network.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: network.color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, size: 14, color: network.color),
                    const SizedBox(width: 6),
                    Text(f,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: network.color)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
