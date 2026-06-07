import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/snack.dart';
import '../../data/models/integration.dart' as model_integration;
import '../../data/providers/integrations_providers.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/campaign.dart';
import '../../data/providers/campaigns_providers.dart';
import '../../data/providers/workspace_providers.dart';
import 'widgets/campaign_launch_sheet.dart';
import 'widgets/negative_keywords_panel.dart';
import 'widgets/automation_rules_panel.dart';

class AdsManagerScreen extends ConsumerStatefulWidget {
  const AdsManagerScreen({super.key});
  @override
  ConsumerState<AdsManagerScreen> createState() => _AdsManagerScreenState();
}

class _AdsManagerScreenState extends ConsumerState<AdsManagerScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 4, vsync: this);
  AdNetwork? _filter;

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _launch() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CampaignLaunchSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(campaignsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(onLaunch: _launch),
          AppSpacing.vGapXl,
          const _AdNetworkPicker(),
          AppSpacing.vGapXl,
          const _AdsKpiRow(),
          AppSpacing.vGapXl,
          _NetworkChips(
            selected: _filter,
            onChanged: (v) => setState(() => _filter = v),
          ),
          AppSpacing.vGapMd,
          TabBar(
            controller: _tab,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Campaigns'),
              Tab(text: 'Ad sets'),
              Tab(text: 'Negative keywords'),
              Tab(text: 'Automation rules'),
            ],
          ),
          const Divider(height: 1),
          SizedBox(
            height: 720,
            child: TabBarView(
              controller: _tab,
              children: [
                _CampaignsTab(async: async, filter: _filter),
                _AdSetsTab(),
                const NegativeKeywordsPanel(),
                const AutomationRulesPanel(),
              ],
            ),
          ),
          AppSpacing.vGapXxl,
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onLaunch});
  final VoidCallback onLaunch;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ads Manager', style: Theme.of(context).textTheme.headlineLarge),
              AppSpacing.vGapXs,
              Text(
                'One cockpit for Google, Meta, TikTok, LinkedIn, X & more — managed by MYTHRIX.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
              ),
            ],
          ),
        ),
        if (MediaQuery.sizeOf(context).width >= 900) ...[
          OutlinedButton.icon(
            onPressed: () => Snack.info(context,
                'Real Google/Meta/LinkedIn OAuth lands in Phase 4. Until then, Mythrix simulates launches locally.'),
            icon: const Icon(Icons.link_rounded, size: 16),
            label: const Text('Connect account'),
          ),
          AppSpacing.hGapSm,
          GradientButton(
            label: 'Launch with MYTHRIX',
            icon: Icons.rocket_launch_rounded,
            onPressed: onLaunch,
          ),
        ],
      ],
    );
  }
}

class _AdNetworkPicker extends ConsumerWidget {
  const _AdNetworkPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(integrationsProvider);
    final networks = all.where((i) => i.category == model_integration.IntegrationCategory.ads).toList();
    final w = MediaQuery.sizeOf(context).width;
    final cols = w >= 1400 ? 4 : (w >= 900 ? 3 : (w >= 600 ? 2 : 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Your ad networks',
          subtitle: 'Each network gets its own dedicated workspace — never combined',
          icon: Icons.hub_rounded,
        ),
        GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 2.6,
          children: [
            for (final n in networks) _NetworkTile(network: n),
          ],
        ),
      ],
    );
  }
}

class _NetworkTile extends StatelessWidget {
  const _NetworkTile({required this.network});
  final model_integration.Integration network;

  @override
  Widget build(BuildContext context) {
    final connected = network.status == model_integration.IntegrationStatus.connected;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      hoverable: true,
      onTap: () => context.go('/app/ads/${network.id}'),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: network.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(network.category.icon, color: network.color, size: 18),
          ),
          AppSpacing.hGapSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(network.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: connected ? AppColors.success : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      connected ? 'Live' : 'Not connected',
                      style: TextStyle(
                        fontSize: 11,
                        color: connected ? AppColors.success : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
        ],
      ),
    );
  }
}

class _AdsKpiRow extends StatelessWidget {
  const _AdsKpiRow();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = w >= 1400 ? 4 : (w >= 900 ? 3 : (w >= 600 ? 2 : 1));

    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      mainAxisSpacing: AppSpacing.lg,
      crossAxisSpacing: AppSpacing.lg,
      children: const [
        KpiCard(
          label: 'Active spend (today)',
          value: '\$2,418',
          delta: '+8.4%',
          trend: TrendDirection.up,
          icon: Icons.payments_rounded,
          accent: AppColors.mythrixViolet,
        ),
        KpiCard(
          label: 'Conversions (24h)',
          value: '184',
          delta: '+12.6%',
          trend: TrendDirection.up,
          icon: Icons.task_alt_rounded,
          accent: AppColors.mythrixLime,
        ),
        KpiCard(
          label: 'CPA',
          value: '\$13.14',
          delta: '-4.1%',
          trend: TrendDirection.down,
          icon: Icons.swap_horiz_rounded,
          accent: AppColors.mythrixCyan,
        ),
        KpiCard(
          label: 'Auto-optimizations (24h)',
          value: '47',
          delta: '+22',
          trend: TrendDirection.up,
          icon: Icons.auto_awesome_rounded,
          accent: AppColors.mythrixMagenta,
        ),
      ],
    );
  }
}

class _NetworkChips extends StatelessWidget {
  const _NetworkChips({required this.selected, required this.onChanged});
  final AdNetwork? selected;
  final ValueChanged<AdNetwork?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        FilterChip(
          label: const Text('All networks'),
          selected: selected == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final n in AdNetwork.values)
          FilterChip(
            label: Text(n.displayName),
            selected: selected == n,
            onSelected: (_) => onChanged(n),
          ),
      ],
    );
  }
}

class _CampaignsTab extends ConsumerWidget {
  const _CampaignsTab({required this.async, required this.filter});
  final AsyncValue<List<Campaign>> async;
  final AdNetwork? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final launched = ref.watch(campaignsStoreProvider);
    final live = launched.map((c) => c.toCampaign()).toList();

    return async.when(
      data: (campaigns) {
        // User's real launches first, then seed mocks.
        final all = [...live, ...campaigns];
        final filtered =
            filter == null ? all : all.where((c) => c.network == filter).toList();

        if (filtered.isEmpty) {
          return const EmptyState(
            icon: Icons.campaign_rounded,
            title: 'No campaigns on this network yet',
            message: 'Connect your account or let MYTHRIX launch your first campaign.',
          );
        }

        // Mark the live ones with a "Just launched" banner row when present.
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          itemCount: filtered.length + (live.isNotEmpty ? 1 : 0),
          itemBuilder: (_, i) {
            if (live.isNotEmpty && i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.mythrixViolet.withValues(alpha: 0.18),
                      AppColors.mythrixCyan.withValues(alpha: 0.12),
                    ]),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                        color: AppColors.mythrixViolet.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.rocket_launch_rounded,
                          size: 16, color: AppColors.mythrixViolet),
                      AppSpacing.hGapSm,
                      Expanded(
                        child: Text(
                          'You\'ve launched ${live.length} campaign${live.length == 1 ? '' : 's'} — they\'re live below.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            final c = filtered[live.isNotEmpty ? i - 1 : i];
            return _CampaignRow(campaign: c);
          },
        );
      },
      error: (e, _) => Center(child: Text('Error: $e')),
      loading: () => const Center(child: MythrixLoader()),
    );
  }
}

class _CampaignRow extends StatelessWidget {
  const _CampaignRow({required this.campaign});
  final Campaign campaign;

  PillTone get _tone {
    return switch (campaign.status) {
      CampaignStatus.active => PillTone.success,
      CampaignStatus.paused => PillTone.warning,
      CampaignStatus.scheduled => PillTone.info,
      CampaignStatus.error => PillTone.danger,
      _ => PillTone.neutral,
    };
  }

  String get _statusLabel => switch (campaign.status) {
        CampaignStatus.active => 'Active',
        CampaignStatus.paused => 'Paused',
        CampaignStatus.scheduled => 'Scheduled',
        CampaignStatus.draft => 'Draft',
        CampaignStatus.completed => 'Completed',
        CampaignStatus.error => 'Error',
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(campaign.name, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis)),
                        AppSpacing.hGapSm,
                        StatusPill(label: _statusLabel, tone: _tone, dense: true),
                      ],
                    ),
                    AppSpacing.vGapXxs,
                    Text(
                      '${campaign.network.displayName} · ${campaign.objective.displayName} · ${campaign.audience}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: campaign.status == CampaignStatus.active,
                onChanged: (_) {
                  Snack.info(context,
                      'Pausing this seed campaign is a no-op. Real toggling works on campaigns you launched via "Launch with MYTHRIX".');
                },
              ),
              IconButton(
                onPressed: () => Snack.info(context,
                    'Per-campaign actions menu (duplicate, archive, export) ships in the next pass.'),
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
          AppSpacing.vGapSm,
          LayoutBuilder(builder: (context, c) {
            final compact = c.maxWidth < 640;
            final metrics = [
              _Metric('Spend', Fmt.money(campaign.spend)),
              _Metric('Revenue', Fmt.money(campaign.revenue)),
              _Metric('Conv', Fmt.decimal(campaign.conversions)),
              _Metric('CTR', Fmt.percent(campaign.ctr)),
              _Metric('CPA', Fmt.money(campaign.cpa)),
              _Metric('ROAS', '${campaign.roas.toStringAsFixed(2)}×',
                  highlight: campaign.roas >= 3
                      ? AppColors.success
                      : (campaign.roas >= 1.5 ? AppColors.warning : AppColors.danger)),
            ];
            if (compact) {
              return Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.sm,
                children: metrics,
              );
            }
            return Row(
              children: [
                for (final m in metrics) Expanded(child: m),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, {this.highlight});
  final String label;
  final String value;
  final Color? highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
        Text(value, style: AppTypography.mono(size: 14, weight: FontWeight.w700, color: highlight)),
      ],
    );
  }
}

class _AdSetsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Ad sets & audiences',
              subtitle: 'Granular audience targeting across networks',
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final r in _rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 28,
                      decoration: BoxDecoration(color: r.color, borderRadius: BorderRadius.circular(2)),
                    ),
                    AppSpacing.hGapSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name, style: Theme.of(context).textTheme.titleSmall),
                          Text(r.audience,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  )),
                        ],
                      ),
                    ),
                    Text('Reach: ${r.reach}', style: AppTypography.mono(size: 12)),
                    AppSpacing.hGapMd,
                    StatusPill(label: '${r.ctr.toStringAsFixed(2)}% CTR', tone: PillTone.success, dense: true),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  static final _rows = [
    _AdSet('Lookalike 1% · purchasers', 'Meta', '1.8M', 3.2, AppColors.mythrixCyan),
    _AdSet('Decision-makers · MarTech', 'LinkedIn', '420K', 1.8, AppColors.mythrixIndigo),
    _AdSet('Custom intent — competitors', 'Google', '910K', 4.4, AppColors.mythrixAmber),
    _AdSet('Gen Z · trending sounds', 'TikTok', '6.4M', 5.1, AppColors.mythrixPink),
  ];
}

class _AdSet {
  _AdSet(this.name, this.audience, this.reach, this.ctr, this.color);
  final String name;
  final String audience;
  final String reach;
  final double ctr;
  final Color color;
}
