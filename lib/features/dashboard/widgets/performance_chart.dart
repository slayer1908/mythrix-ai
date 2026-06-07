import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/services/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_pill.dart';

class PerformanceChart extends StatefulWidget {
  const PerformanceChart({super.key});
  @override
  State<PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends State<PerformanceChart> {
  int _range = 30;

  late final List<double> _revenue = MockData.trend(base: 4200, drift: 38, noise: 380);
  late final List<double> _spend = MockData.trend(base: 1500, drift: 6, noise: 120);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.5);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Performance',
            subtitle: 'Revenue vs ad spend over time',
            trailing: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 7, label: Text('7d')),
                ButtonSegment(value: 30, label: Text('30d')),
                ButtonSegment(value: 90, label: Text('90d')),
              ],
              selected: {_range},
              showSelectedIcon: false,
              onSelectionChanged: (v) => setState(() => _range = v.first),
            ),
          ),
          Row(
            children: const [
              _LegendDot(color: AppColors.mythrixCyan, label: 'Revenue'),
              SizedBox(width: AppSpacing.md),
              _LegendDot(color: AppColors.mythrixViolet, label: 'Spend'),
              SizedBox(width: AppSpacing.md),
              StatusPill(
                tone: PillTone.success,
                label: 'ROAS 4.52×',
              ),
            ],
          ),
          AppSpacing.vGapMd,
          AspectRatio(
            aspectRatio: 16 / 8,
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2000,
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
                      reservedSize: 44,
                      interval: 2000,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          '\$${(v / 1000).toStringAsFixed(0)}k',
                          style: TextStyle(color: muted, fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'D${v.toInt() + 1}',
                          style: TextStyle(color: muted, fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => scheme.surfaceContainerHigh,
                    tooltipBorder: BorderSide(color: scheme.outline),
                    tooltipRoundedRadius: 10,
                  ),
                ),
                lineBarsData: [
                  _series(_revenue, AppColors.mythrixCyan),
                  _series(_spend, AppColors.mythrixViolet),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _series(List<double> values, Color color) {
    return LineChartBarData(
      spots: [
        for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
      ],
      isCurved: true,
      curveSmoothness: 0.32,
      barWidth: 2.5,
      color: color,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
