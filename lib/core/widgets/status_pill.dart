import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum PillTone { neutral, success, warning, danger, info, brand }

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.tone = PillTone.neutral,
    this.icon,
    this.dense = false,
  });

  final String label;
  final PillTone tone;
  final IconData? icon;
  final bool dense;

  Color _bg(BuildContext context) {
    switch (tone) {
      case PillTone.success:
        return AppColors.success.withValues(alpha: 0.14);
      case PillTone.warning:
        return AppColors.warning.withValues(alpha: 0.14);
      case PillTone.danger:
        return AppColors.danger.withValues(alpha: 0.14);
      case PillTone.info:
        return AppColors.info.withValues(alpha: 0.14);
      case PillTone.brand:
        return AppColors.mythrixViolet.withValues(alpha: 0.14);
      case PillTone.neutral:
        return Theme.of(context).colorScheme.surfaceContainerHigh;
    }
  }

  Color _fg(BuildContext context) {
    switch (tone) {
      case PillTone.success:
        return AppColors.success;
      case PillTone.warning:
        return AppColors.warning;
      case PillTone.danger:
        return AppColors.danger;
      case PillTone.info:
        return AppColors.info;
      case PillTone.brand:
        return AppColors.mythrixViolet;
      case PillTone.neutral:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = _fg(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.xs : AppSpacing.sm,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _bg(context),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 10 : 12, color: fg),
            const SizedBox(width: 4),
          ] else if (tone != PillTone.neutral) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: dense ? 10 : 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
