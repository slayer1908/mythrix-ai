import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_pill.dart';

class SeoScreen extends StatelessWidget {
  const SeoScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              KpiCard(label: 'Organic sessions', value: '184K', delta: '+12%', trend: TrendDirection.up, icon: Icons.travel_explore_rounded, accent: AppColors.mythrixLime),
              KpiCard(label: 'Avg position', value: '4.2', delta: '-0.6', trend: TrendDirection.up, icon: Icons.format_list_numbered_rounded, accent: AppColors.mythrixCyan),
              KpiCard(label: 'Backlinks', value: '12.4K', delta: '+248', trend: TrendDirection.up, icon: Icons.link_rounded, accent: AppColors.mythrixViolet),
              KpiCard(label: 'Core Web Vitals', value: '92', delta: '+4', trend: TrendDirection.up, icon: Icons.speed_rounded, accent: AppColors.mythrixMagenta),
            ],
          ),
          AppSpacing.vGapXl,
          const _KeywordExplorer(),
          AppSpacing.vGapXl,
          const _SiteAudit(),
          AppSpacing.vGapXxl,
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SEO', style: Theme.of(context).textTheme.headlineLarge),
              AppSpacing.vGapXs,
              Text(
                'AI-driven keyword research, content briefs, and site audits.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
              ),
            ],
          ),
        ),
        const GradientButton(
          label: 'Run AI audit',
          icon: Icons.auto_awesome_rounded,
          onPressed: _noop,
        ),
      ],
    );
  }

  static void _noop() {}
}

class _KeywordExplorer extends StatelessWidget {
  const _KeywordExplorer();

  static const _rows = [
    ('ai marketing automation', 18000, 'Medium', 4, 'rising'),
    ('autonomous marketing platform', 4400, 'High', 8, 'rising'),
    ('best marketing ai 2026', 9800, 'High', 11, 'rising'),
    ('marketing copilot software', 2900, 'Medium', 5, 'flat'),
    ('automated ad optimization', 12100, 'Medium', 6, 'rising'),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Keyword opportunities',
            subtitle: 'High-intent terms MYTHRIX recommends pursuing',
            trailing: Builder(builder: (ctx) => TextButton(
              onPressed: () => Snack.info(ctx, 'Full keyword explorer launching with the SEO module in Phase 6.'),
              child: const Text('Open explorer'),
            )),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 28,
              headingRowHeight: 36,
              columns: const [
                DataColumn(label: Text('KEYWORD')),
                DataColumn(label: Text('MONTHLY'), numeric: true),
                DataColumn(label: Text('DIFFICULTY')),
                DataColumn(label: Text('YOUR RANK'), numeric: true),
                DataColumn(label: Text('TREND')),
                DataColumn(label: Text('')),
              ],
              rows: [
                for (final r in _rows)
                  DataRow(cells: [
                    DataCell(Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(r.$2.toString(), style: AppTypography.mono(size: 12))),
                    DataCell(StatusPill(label: r.$3, tone: r.$3 == 'High' ? PillTone.warning : PillTone.info, dense: true)),
                    DataCell(Text('#${r.$4}', style: AppTypography.mono(size: 12, color: AppColors.success))),
                    DataCell(Icon(
                      r.$5 == 'rising' ? Icons.trending_up_rounded : Icons.trending_flat_rounded,
                      color: r.$5 == 'rising' ? AppColors.success : AppColors.textLow,
                      size: 18,
                    )),
                    DataCell(Builder(builder: (ctx) => TextButton(
                      onPressed: () => Snack.info(ctx, 'Mythrix will generate a full content brief for "${r.$1}" — shipping in the SEO module.'),
                      child: const Text('Brief'),
                    ))),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SiteAudit extends StatelessWidget {
  const _SiteAudit();

  static const _issues = [
    ('212 pages missing meta description', 'medium', Icons.description_outlined),
    ('14 pages with thin content (<300 words)', 'high', Icons.warning_amber_rounded),
    ('Largest Contentful Paint > 2.5s on 8 pages', 'medium', Icons.speed_rounded),
    ('39 broken internal links detected', 'high', Icons.link_off_rounded),
    ('Missing schema on 4 product pages', 'low', Icons.code_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Site audit',
            subtitle: 'Issues prioritized by impact',
            icon: Icons.fact_check_outlined,
          ),
          for (final i in _issues)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(i.$3, color: _color(i.$2), size: 20),
                  AppSpacing.hGapMd,
                  Expanded(child: Text(i.$1, style: Theme.of(context).textTheme.bodyMedium)),
                  StatusPill(label: i.$2.toUpperCase(), tone: _tone(i.$2), dense: true),
                  AppSpacing.hGapSm,
                  Builder(builder: (ctx) => TextButton(
                    onPressed: () => Snack.info(ctx, 'Auto-fix for "${i.$1}" queued for the next Mythrix run.'),
                    child: const Text('Fix with MYTHRIX'),
                  )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _color(String s) => switch (s) {
        'high' => AppColors.danger,
        'medium' => AppColors.warning,
        _ => AppColors.info,
      };

  PillTone _tone(String s) => switch (s) {
        'high' => PillTone.danger,
        'medium' => PillTone.warning,
        _ => PillTone.info,
      };
}
