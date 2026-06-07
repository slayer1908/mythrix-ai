import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'glass_card.dart';

enum TrendDirection { up, down, flat }

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.trend = TrendDirection.flat,
    this.icon,
    this.accent = AppColors.mythrixViolet,
    this.sparkline,
    this.onTap,
  });

  final String label;
  final String value;
  final String? delta;
  final TrendDirection trend;
  final IconData? icon;
  final Color accent;
  final Widget? sparkline;
  final VoidCallback? onTap;

  Color get _trendColor {
    switch (trend) {
      case TrendDirection.up:
        return AppColors.success;
      case TrendDirection.down:
        return AppColors.danger;
      case TrendDirection.flat:
        return AppColors.textLow;
    }
  }

  IconData get _trendIcon {
    switch (trend) {
      case TrendDirection.up:
        return Icons.trending_up_rounded;
      case TrendDirection.down:
        return Icons.trending_down_rounded;
      case TrendDirection.flat:
        return Icons.trending_flat_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.6);

    return GlassCard(
      onTap: onTap,
      hoverable: onTap != null,
      glowColor: accent,
      glowIntensity: 0.15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent.withValues(alpha: 0.25), accent.withValues(alpha: 0.08)],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: accent.withValues(alpha: 0.25)),
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
              if (icon != null) AppSpacing.hGapSm,
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: muted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.vGapSm,
          Text(value, style: AppTypography.kpiNumber(size: 32, color: scheme.onSurface)),
          AppSpacing.vGapXs,
          Row(
            children: [
              if (delta != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _trendColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_trendIcon, size: 12, color: _trendColor),
                      const SizedBox(width: 2),
                      Text(
                        delta!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _trendColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGapXs,
                Expanded(
                  child: Text(
                    'vs last period',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: muted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (sparkline != null)
                SizedBox(width: 64, height: 28, child: sparkline),
            ],
          ),
        ],
      ),
    );
  }
}
