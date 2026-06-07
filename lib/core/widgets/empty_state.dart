import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.mythrixViolet.withValues(alpha: 0.18),
                    AppColors.mythrixCyan.withValues(alpha: 0.10),
                  ],
                ),
                border: Border.all(color: AppColors.mythrixViolet.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, size: 40, color: AppColors.mythrixViolet),
            ),
            AppSpacing.vGapLg,
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (message != null) ...[
              AppSpacing.vGapSm,
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ),
            ],
            if (action != null) ...[
              AppSpacing.vGapLg,
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
