import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_pill.dart';

class BestTimePanel extends StatelessWidget {
  const BestTimePanel({super.key});

  static const _windows = [
    ('Instagram', 'Tue · 11:42 AM', 92, AppColors.mythrixMagenta),
    ('LinkedIn', 'Wed · 8:15 AM', 88, AppColors.mythrixIndigo),
    ('X / Twitter', 'Thu · 9:00 PM', 81, AppColors.mythrixCyan),
    ('TikTok', 'Fri · 7:30 PM', 78, AppColors.mythrixPink),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Best time to post',
            subtitle: 'Optimal windows from your audience\'s behavior',
            icon: Icons.schedule_rounded,
            trailing: const StatusPill(label: 'AI · TZ-aware', tone: PillTone.brand, dense: true),
          ),
          for (final w in _windows) ...[
            _WindowRow(channel: w.$1, time: w.$2, confidence: w.$3, color: w.$4),
            AppSpacing.vGapSm,
          ],
          const Divider(),
          AppSpacing.vGapSm,
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: AppColors.success, size: 16),
                AppSpacing.hGapSm,
                const Expanded(
                  child: Text(
                    'Posting at the optimal window typically lifts engagement by 34%.',
                    style: TextStyle(fontSize: 12),
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

class _WindowRow extends StatelessWidget {
  const _WindowRow({
    required this.channel,
    required this.time,
    required this.confidence,
    required this.color,
  });
  final String channel;
  final String time;
  final int confidence;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 28,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        AppSpacing.hGapSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(channel, style: Theme.of(context).textTheme.titleSmall),
              Text(time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      )),
            ],
          ),
        ),
        SizedBox(
          width: 44,
          child: Text('$confidence%',
              textAlign: TextAlign.right,
              style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
