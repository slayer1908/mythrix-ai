import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_header.dart';

class _Slice {
  const _Slice(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

class ChannelMixChart extends StatefulWidget {
  const ChannelMixChart({super.key});
  @override
  State<ChannelMixChart> createState() => _ChannelMixChartState();
}

class _ChannelMixChartState extends State<ChannelMixChart> {
  int? _touched;

  static const _slices = [
    _Slice('Google Ads', 38, AppColors.mythrixViolet),
    _Slice('Meta Ads', 28, AppColors.mythrixCyan),
    _Slice('LinkedIn', 14, AppColors.mythrixMagenta),
    _Slice('TikTok', 12, AppColors.mythrixLime),
    _Slice('Other', 8, AppColors.mythrixAmber),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Channel mix',
            subtitle: 'Share of spend by network',
          ),
          AspectRatio(
            aspectRatio: 1.4,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 56,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            _touched = response?.touchedSection?.touchedSectionIndex;
                          });
                        },
                      ),
                      sections: [
                        for (var i = 0; i < _slices.length; i++)
                          PieChartSectionData(
                            value: _slices[i].value,
                            color: _slices[i].color,
                            radius: _touched == i ? 56 : 48,
                            title: '${_slices[i].value.toInt()}%',
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final s in _slices) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: s.color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              AppSpacing.hGapSm,
                              Expanded(
                                child: Text(
                                  s.label,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${s.value.toInt()}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
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
