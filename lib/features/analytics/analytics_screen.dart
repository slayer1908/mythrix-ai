import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_pill.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1180;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(),
          AppSpacing.vGapXl,
          const _KpiRow(),
          AppSpacing.vGapXl,
          if (wide)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(flex: 3, child: _AttributionChart()),
                  AppSpacing.hGapLg,
                  Expanded(flex: 2, child: _FunnelCard()),
                ],
              ),
            )
          else
            Column(
              children: const [
                _AttributionChart(),
                AppSpacing.vGapLg,
                _FunnelCard(),
              ],
            ),
          AppSpacing.vGapXl,
          const _CohortHeatmap(),
          AppSpacing.vGapXl,
          const _AudienceBreakdown(),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analytics', style: Theme.of(context).textTheme.headlineLarge),
              AppSpacing.vGapXs,
              Text(
                'Cross-channel attribution. Real revenue. Truth that compounds.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
              ),
            ],
          ),
        ),
        if (MediaQuery.sizeOf(context).width >= 900) ...[
          OutlinedButton.icon(
            onPressed: () => Snack.info(context, 'Custom-dashboard builder ships with the analytics rewrite in Phase 6.'),
            icon: const Icon(Icons.tune_rounded, size: 16),
            label: const Text('Build dashboard'),
          ),
          AppSpacing.hGapSm,
          const GradientButton(
            label: 'AI report',
            icon: Icons.auto_awesome_rounded,
            onPressed: _noop,
          ),
        ],
      ],
    );
  }

  static void _noop() {}
}

class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = w >= 1400 ? 4 : (w >= 900 ? 2 : 1);
    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      mainAxisSpacing: AppSpacing.lg,
      crossAxisSpacing: AppSpacing.lg,
      children: const [
        KpiCard(
          label: 'Marketing-attributed revenue',
          value: '\$218,340',
          delta: '+24.6%',
          trend: TrendDirection.up,
          icon: Icons.payments_rounded,
          accent: AppColors.mythrixLime,
        ),
        KpiCard(
          label: 'Pipeline value',
          value: '\$1.42M',
          delta: '+18.2%',
          trend: TrendDirection.up,
          icon: Icons.account_balance_rounded,
          accent: AppColors.mythrixCyan,
        ),
        KpiCard(
          label: 'LTV : CAC',
          value: '6.8×',
          delta: '+0.6×',
          trend: TrendDirection.up,
          icon: Icons.balance_rounded,
          accent: AppColors.mythrixViolet,
        ),
        KpiCard(
          label: 'Retention (90d)',
          value: '78.4%',
          delta: '+2.1pp',
          trend: TrendDirection.up,
          icon: Icons.favorite_rounded,
          accent: AppColors.mythrixMagenta,
        ),
      ],
    );
  }
}

class _AttributionChart extends StatelessWidget {
  const _AttributionChart();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.5);

    final data = [
      _ChannelBar('Google', 78, AppColors.mythrixAmber),
      _ChannelBar('Meta', 64, AppColors.mythrixCyan),
      _ChannelBar('Direct', 42, AppColors.mythrixViolet),
      _ChannelBar('Email', 28, AppColors.mythrixCoral),
      _ChannelBar('Organic', 24, AppColors.mythrixLime),
      _ChannelBar('LinkedIn', 18, AppColors.mythrixIndigo),
      _ChannelBar('TikTok', 12, AppColors.mythrixPink),
    ];

    final maxY = data.map((d) => d.value).reduce((a, b) => a > b ? a : b).toDouble();

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Channel attribution',
            subtitle: 'Multi-touch revenue contribution',
          ),
          AspectRatio(
            aspectRatio: 16 / 7,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.1,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: scheme.outline.withValues(alpha: 0.4),
                    strokeWidth: 1,
                    dashArray: [4, 6],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text('\$${v.toInt()}k',
                            style: TextStyle(color: muted, fontSize: 10)),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= data.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            data[i].label,
                            style: TextStyle(color: muted, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < data.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data[i].value.toDouble(),
                          width: 22,
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [data[i].color.withValues(alpha: 0.6), data[i].color],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelBar {
  const _ChannelBar(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
}

class _FunnelCard extends StatelessWidget {
  const _FunnelCard();

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Impressions', 1840000, 1.0, AppColors.mythrixCyan),
      ('Clicks', 84200, 0.78, AppColors.mythrixViolet),
      ('Visits', 62300, 0.68, AppColors.mythrixMagenta),
      ('Add to cart', 8120, 0.32, AppColors.mythrixAmber),
      ('Purchases', 3128, 0.18, AppColors.mythrixLime),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Conversion funnel',
            subtitle: 'Last 30 days · all channels',
          ),
          for (var i = 0; i < steps.length; i++) ...[
            _FunnelStep(
              label: steps[i].$1,
              value: Fmt.compact(steps[i].$2),
              widthFraction: steps[i].$3,
              color: steps[i].$4,
              dropRate: i == 0
                  ? null
                  : ((steps[i - 1].$2 - steps[i].$2) / steps[i - 1].$2),
            ),
            if (i != steps.length - 1) AppSpacing.vGapSm,
          ],
        ],
      ),
    );
  }
}

class _FunnelStep extends StatelessWidget {
  const _FunnelStep({
    required this.label,
    required this.value,
    required this.widthFraction,
    required this.color,
    required this.dropRate,
  });
  final String label;
  final String value;
  final double widthFraction;
  final Color color;
  final double? dropRate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.titleSmall)),
            Text(value, style: AppTypography.mono(size: 13, weight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, c) {
            return Stack(
              children: [
                Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                Container(
                  width: c.maxWidth * widthFraction,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color.withValues(alpha: 0.7), color]),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ],
            );
          },
        ),
        if (dropRate != null) ...[
          const SizedBox(height: 2),
          Text(
            '${(dropRate! * 100).toStringAsFixed(1)}% drop-off',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                ),
          ),
        ],
      ],
    );
  }
}

class _CohortHeatmap extends StatelessWidget {
  const _CohortHeatmap();

  static const _cohorts = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
  static const _weeks = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6'];

  double _value(int c, int w) {
    final base = 0.95 - (w * 0.08) + (c * 0.015);
    return base.clamp(0.18, 0.98);
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Retention cohorts',
            subtitle: 'Weekly return rate by acquisition cohort',
            icon: Icons.grid_view_rounded,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 56),
                    for (final w in _weeks)
                      SizedBox(
                        width: 80,
                        child: Center(
                          child: Text(
                            w,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
                for (var c = 0; c < _cohorts.length; c++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 56,
                          child: Text(_cohorts[c],
                              style: Theme.of(context).textTheme.labelSmall),
                        ),
                        for (var w = 0; w < _weeks.length; w++) ...[
                          _Cell(value: _value(c, w)),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.mythrixViolet.withValues(alpha: value * 0.9),
            AppColors.mythrixCyan.withValues(alpha: value * 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      alignment: Alignment.center,
      child: Text(
        '${(value * 100).toInt()}%',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _AudienceBreakdown extends StatelessWidget {
  const _AudienceBreakdown();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Top converting segments',
            subtitle: 'Audiences MYTHRIX wants you to invest more in',
            trailing: StatusPill(label: 'AI-ranked', tone: PillTone.brand, dense: true),
          ),
          for (final s in _segments)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [s.color, s.color.withValues(alpha: 0.6)]),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      s.name.substring(0, 1),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: Theme.of(context).textTheme.titleSmall),
                        Text(s.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                                )),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(s.cvr, style: AppTypography.mono(weight: FontWeight.w700, color: AppColors.success)),
                      Text('${s.revenue} revenue',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                              )),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static const _segments = [
    _Segment('Repeat customers', 'Bought 2+ times in 90 days', '12.4%', '\$48k', AppColors.mythrixLime),
    _Segment('High-intent — search', 'Branded + competitor terms', '8.6%', '\$36k', AppColors.mythrixAmber),
    _Segment('Lookalike 1% — purchasers', 'Meta + TikTok', '5.2%', '\$22k', AppColors.mythrixCyan),
    _Segment('Decision-makers · MarTech', 'LinkedIn, 200+ employees', '4.1%', '\$31k', AppColors.mythrixIndigo),
  ];
}

class _Segment {
  const _Segment(this.name, this.description, this.cvr, this.revenue, this.color);
  final String name;
  final String description;
  final String cvr;
  final String revenue;
  final Color color;
}
