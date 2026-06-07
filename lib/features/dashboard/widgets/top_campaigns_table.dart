import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../data/models/campaign.dart';
import '../../../data/providers/workspace_providers.dart';

class TopCampaignsTable extends ConsumerWidget {
  const TopCampaignsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(campaignsProvider);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Top campaigns',
            subtitle: 'Best performers by ROAS in the last 30 days',
            trailing: TextButton.icon(
              onPressed: () => context.go('/app/ads'),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('All campaigns'),
            ),
          ),
          async.when(
            data: (campaigns) {
              final sorted = [...campaigns]..sort((a, b) => b.roas.compareTo(a.roas));
              return _Table(campaigns: sorted.take(6).toList());
            },
            error: (e, _) => Text('Could not load: $e'),
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: MythrixLoader()),
            ),
          ),
        ],
      ),
    );
  }
}

class _Table extends StatelessWidget {
  const _Table({required this.campaigns});
  final List<Campaign> campaigns;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.55);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.sizeOf(context).width - 96,
        ),
        child: DataTable(
          headingRowHeight: 36,
          dataRowMinHeight: 56,
          dataRowMaxHeight: 64,
          columnSpacing: 28,
          dividerThickness: 0.5,
          headingTextStyle: TextStyle(
            color: muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
          columns: const [
            DataColumn(label: Text('CAMPAIGN')),
            DataColumn(label: Text('NETWORK')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('SPEND'), numeric: true),
            DataColumn(label: Text('REVENUE'), numeric: true),
            DataColumn(label: Text('CONV'), numeric: true),
            DataColumn(label: Text('ROAS'), numeric: true),
          ],
          rows: [
            for (final c in campaigns)
              DataRow(
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_iconFor(c.network), size: 16, color: _colorFor(c.network)),
                        AppSpacing.hGapSm,
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 240),
                          child: Text(
                            c.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(c.network.displayName)),
                  DataCell(StatusPill(label: _statusLabel(c.status), tone: _statusTone(c.status))),
                  DataCell(Text(Fmt.money(c.spend), style: AppTypography.mono(color: scheme.onSurface))),
                  DataCell(Text(Fmt.money(c.revenue), style: AppTypography.mono(color: scheme.onSurface))),
                  DataCell(Text(Fmt.decimal(c.conversions), style: AppTypography.mono(color: scheme.onSurface))),
                  DataCell(
                    Text(
                      '${c.roas.toStringAsFixed(2)}×',
                      style: AppTypography.mono(
                        color: c.roas >= 3
                            ? AppColors.success
                            : (c.roas >= 1.5 ? AppColors.warning : AppColors.danger),
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(AdNetwork n) {
    switch (n) {
      case AdNetwork.googleAds:
        return Icons.search_rounded;
      case AdNetwork.metaAds:
        return Icons.facebook_rounded;
      case AdNetwork.tiktokAds:
        return Icons.music_note_rounded;
      case AdNetwork.linkedinAds:
        return Icons.work_outline_rounded;
      case AdNetwork.xAds:
        return Icons.tag_rounded;
      case AdNetwork.microsoftAds:
        return Icons.window_rounded;
      case AdNetwork.pinterestAds:
        return Icons.push_pin_rounded;
      case AdNetwork.redditAds:
        return Icons.reddit_rounded;
    }
  }

  Color _colorFor(AdNetwork n) {
    switch (n) {
      case AdNetwork.googleAds:
        return AppColors.mythrixAmber;
      case AdNetwork.metaAds:
        return AppColors.mythrixCyan;
      case AdNetwork.tiktokAds:
        return AppColors.mythrixMagenta;
      case AdNetwork.linkedinAds:
        return AppColors.mythrixIndigo;
      default:
        return AppColors.mythrixViolet;
    }
  }

  String _statusLabel(CampaignStatus s) {
    return switch (s) {
      CampaignStatus.active => 'Active',
      CampaignStatus.paused => 'Paused',
      CampaignStatus.scheduled => 'Scheduled',
      CampaignStatus.draft => 'Draft',
      CampaignStatus.completed => 'Done',
      CampaignStatus.error => 'Error',
    };
  }

  PillTone _statusTone(CampaignStatus s) {
    return switch (s) {
      CampaignStatus.active => PillTone.success,
      CampaignStatus.paused => PillTone.warning,
      CampaignStatus.scheduled => PillTone.info,
      CampaignStatus.draft => PillTone.neutral,
      CampaignStatus.completed => PillTone.neutral,
      CampaignStatus.error => PillTone.danger,
    };
  }
}
