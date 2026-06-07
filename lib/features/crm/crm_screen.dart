import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/providers/crm_deals_providers.dart';

class CrmScreen extends ConsumerWidget {
  const CrmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yourDeals = ref.watch(crmDealsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(),
          AppSpacing.vGapXl,
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width >= 1280 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
            childAspectRatio: 1.5,
            children: const [
              KpiCard(label: 'Open pipeline', value: '\$1.42M', delta: '+18%', trend: TrendDirection.up, icon: Icons.account_balance_rounded, accent: AppColors.mythrixLime),
              KpiCard(label: 'New leads (7d)', value: '482', delta: '+62', trend: TrendDirection.up, icon: Icons.person_add_alt_rounded, accent: AppColors.mythrixCyan),
              KpiCard(label: 'Hot leads', value: '38', delta: '+8', trend: TrendDirection.up, icon: Icons.local_fire_department_rounded, accent: AppColors.mythrixCoral),
              KpiCard(label: 'Win rate', value: '32.4%', delta: '+3.1pp', trend: TrendDirection.up, icon: Icons.workspace_premium_rounded, accent: AppColors.mythrixViolet),
            ],
          ),
          AppSpacing.vGapXl,
          if (yourDeals.isNotEmpty) ...[
            _YourPipeline(deals: yourDeals),
            AppSpacing.vGapXl,
          ],
          const _Pipeline(),
          AppSpacing.vGapXxl,
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CRM', style: Theme.of(context).textTheme.headlineLarge),
              AppSpacing.vGapXs,
              Text(
                'AI-prioritized pipeline. Leads scored. Deals tracked.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
              ),
            ],
          ),
        ),
        GradientButton(
          label: 'Add deal',
          icon: Icons.add_rounded,
          onPressed: () => _showAddDealSheet(context, ref),
        ),
      ],
    );
  }

  Future<void> _showAddDealSheet(BuildContext context, WidgetRef ref) async {
    final companyCtrl = TextEditingController();
    final valueCtrl = TextEditingController(text: '25000');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.xl,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add a new deal',
                  style: Theme.of(ctx).textTheme.headlineSmall),
              AppSpacing.vGapMd,
              TextField(
                controller: companyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Company / Lead name',
                  hintText: 'e.g. Acme Inc.',
                  prefixIcon: Icon(Icons.business_rounded),
                ),
              ),
              AppSpacing.vGapSm,
              TextField(
                controller: valueCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Deal value (USD)',
                  hintText: '25000',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
              ),
              AppSpacing.vGapLg,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  AppSpacing.hGapSm,
                  Expanded(
                    child: GradientButton(
                      label: 'Add to pipeline',
                      icon: Icons.add_circle_outline_rounded,
                      onPressed: () {
                        final company = companyCtrl.text.trim();
                        if (company.isEmpty) return;
                        final value =
                            double.tryParse(valueCtrl.text.trim()) ?? 0;
                        ref.read(crmDealsProvider.notifier).add(
                              companyName: company,
                              value: value,
                            );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '✅ Added "$company" to your pipeline (AI scored automatically)'),
                          ),
                        );
                      },
                    ),
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

class _YourPipeline extends ConsumerWidget {
  const _YourPipeline({required this.deals});
  final List<CrmDeal> deals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byStage = ref.read(crmDealsProvider.notifier).byStage;
    final totalValue = deals.fold<double>(0, (sum, d) => sum + d.value);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Your pipeline',
            subtitle:
                '${deals.length} deal${deals.length == 1 ? '' : 's'} · \$${(totalValue / 1000).toStringAsFixed(0)}k total · auto-saved',
            icon: Icons.business_center_rounded,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final stage in DealStage.values) ...[
                  SizedBox(
                    width: 240,
                    child: _StageColumn(
                      stage: stage,
                      deals: byStage[stage] ?? const [],
                    ),
                  ),
                  AppSpacing.hGapMd,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StageColumn extends ConsumerWidget {
  const _StageColumn({required this.stage, required this.deals});
  final DealStage stage;
  final List<CrmDeal> deals;

  Color get _accent {
    return switch (stage) {
      DealStage.newLead => AppColors.mythrixCyan,
      DealStage.qualified => AppColors.mythrixViolet,
      DealStage.proposal => AppColors.mythrixMagenta,
      DealStage.negotiation => AppColors.mythrixAmber,
      DealStage.won => AppColors.mythrixLime,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: _accent, shape: BoxShape.circle),
              ),
              AppSpacing.hGapSm,
              Text(stage.label,
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              Text(
                '${deals.length}',
                style: AppTypography.mono(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
        if (deals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              'Empty',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
            ),
          )
        else
          for (final d in deals) _DealCard(deal: d, accent: _accent),
      ],
    );
  }
}

class _DealCard extends ConsumerWidget {
  const _DealCard({required this.deal, required this.accent});
  final CrmDeal deal;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prev = deal.stage.previous;
    final next = deal.stage.next;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(AppSpacing.sm),
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
                child: Text(
                  deal.companyName,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(deal.valueFormatted,
                  style: AppTypography.mono(weight: FontWeight.w700, size: 12)),
            ],
          ),
          AppSpacing.vGapXs,
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.local_fire_department_rounded,
                    color: accent, size: 10),
              ),
              AppSpacing.hGapXs,
              Text(
                'AI score ${deal.aiScore}',
                style: AppTypography.mono(size: 11, color: accent),
              ),
              const Spacer(),
              if (prev != null)
                InkWell(
                  onTap: () => ref
                      .read(crmDealsProvider.notifier)
                      .moveTo(deal.id, prev),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.chevron_left_rounded, size: 16),
                  ),
                ),
              if (next != null)
                InkWell(
                  onTap: () => ref
                      .read(crmDealsProvider.notifier)
                      .moveTo(deal.id, next),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.chevron_right_rounded, size: 16),
                  ),
                ),
              InkWell(
                onTap: () =>
                    ref.read(crmDealsProvider.notifier).remove(deal.id),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline_rounded, size: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pipeline extends StatelessWidget {
  const _Pipeline();

  static const _stages = [
    ('New', [
      ('Acme — \$24k', 84, AppColors.mythrixCyan),
      ('Brewline — \$48k', 72, AppColors.mythrixCyan),
      ('Nimbus — \$8k', 55, AppColors.mythrixCyan),
    ]),
    ('Qualified', [
      ('Northwind — \$120k', 88, AppColors.mythrixViolet),
      ('Helix — \$32k', 76, AppColors.mythrixViolet),
    ]),
    ('Proposal', [
      ('Glacier — \$96k', 91, AppColors.mythrixMagenta),
    ]),
    ('Negotiation', [
      ('Polar — \$58k', 82, AppColors.mythrixAmber),
      ('Vector — \$140k', 78, AppColors.mythrixAmber),
    ]),
    ('Won', [
      ('Pulse — \$36k', 100, AppColors.mythrixLime),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in _stages) ...[
            SizedBox(
              width: 280,
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: s.$1,
                      subtitle: '${s.$2.length} deals',
                    ),
                    for (final d in s.$2)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.$1, style: Theme.of(context).textTheme.titleSmall),
                            AppSpacing.vGapXs,
                            Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: d.$3.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.local_fire_department_rounded, color: d.$3, size: 10),
                                ),
                                AppSpacing.hGapXs,
                                Text(
                                  'AI score ${d.$2}',
                                  style: AppTypography.mono(size: 11, color: d.$3),
                                ),
                                const Spacer(),
                                const StatusPill(label: 'Active', tone: PillTone.success, dense: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            AppSpacing.hGapMd,
          ],
        ],
      ),
    );
  }
}
