import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../data/models/insight.dart';
import '../../../data/providers/smart_insights_provider.dart';

class InsightsFeed extends ConsumerWidget {
  const InsightsFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(smartInsightsProvider);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Smart Insights',
            subtitle: 'What MYTHRIX learned about your account',
            icon: Icons.lightbulb_outline_rounded,
            trailing: TextButton(onPressed: () => context.go('/app/library'), child: const Text('View all')),
          ),
          Column(
            children: [
              for (final i in insights.take(4)) _InsightRow(insight: i),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.insight});
  final Insight insight;

  /// Map an insight's action label to the route it should navigate to.
  String _routeForAction(String action) {
    final a = action.toLowerCase();
    if (a.contains('variant') || a.contains('image') || a.contains('pin')) return '/app/creative';
    if (a.contains('cross-post') || a.contains('schedule')) return '/app/social';
    if (a.contains('email') || a.contains('sequence') || a.contains('follow-up')) return '/app/email';
    if (a.contains('deal') || a.contains('advance')) return '/app/crm';
    if (a.contains('budget') || a.contains('reallocate')) return '/app/ads';
    if (a.contains('week') || a.contains('auto-run')) return '/app/dashboard';
    return '/app/library';
  }

  Color get _accent {
    switch (insight.severity) {
      case InsightSeverity.opportunity:
        return AppColors.success;
      case InsightSeverity.warning:
        return AppColors.warning;
      case InsightSeverity.critical:
        return AppColors.danger;
      case InsightSeverity.info:
        return AppColors.info;
    }
  }

  PillTone get _tone {
    switch (insight.severity) {
      case InsightSeverity.opportunity:
        return PillTone.success;
      case InsightSeverity.warning:
        return PillTone.warning;
      case InsightSeverity.critical:
        return PillTone.danger;
      case InsightSeverity.info:
        return PillTone.info;
    }
  }

  String get _severityLabel {
    switch (insight.severity) {
      case InsightSeverity.opportunity:
        return 'Opportunity';
      case InsightSeverity.warning:
        return 'Warning';
      case InsightSeverity.critical:
        return 'Critical';
      case InsightSeverity.info:
        return 'Info';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
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
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: _accent, shape: BoxShape.circle),
              ),
              AppSpacing.hGapSm,
              StatusPill(label: _severityLabel, tone: _tone, dense: true),
              AppSpacing.hGapSm,
              Text(
                insight.relatedEntity,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
              ),
              const Spacer(),
              Text(
                Fmt.relative(insight.createdAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
              ),
            ],
          ),
          AppSpacing.vGapSm,
          Text(
            insight.title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          AppSpacing.vGapXs,
          Text(
            insight.summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          if (insight.estimatedImpact.isNotEmpty || insight.action.isNotEmpty) ...[
            AppSpacing.vGapSm,
            Row(
              children: [
                if (insight.estimatedImpact.isNotEmpty) ...[
                  Icon(Icons.bolt_rounded, size: 13, color: _accent),
                  const SizedBox(width: 4),
                  Text(
                    insight.estimatedImpact,
                    style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
                const Spacer(),
                if (insight.action.isNotEmpty)
                  TextButton(
                    onPressed: () => context.go(_routeForAction(insight.action)),
                    child: Text(insight.action),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
