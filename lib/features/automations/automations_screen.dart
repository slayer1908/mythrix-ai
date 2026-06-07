import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/providers/automations_providers.dart';

class AutomationsScreen extends StatelessWidget {
  const AutomationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(),
          AppSpacing.vGapXl,
          const _RecipeGrid(),
          AppSpacing.vGapXl,
          const _ActiveWorkflows(),
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
              Text('Automations', style: Theme.of(context).textTheme.headlineLarge),
              AppSpacing.vGapXs,
              Text(
                'When-this-then-that workflows powered by MYTHRIX intelligence.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
              ),
            ],
          ),
        ),
        const GradientButton(label: 'New workflow', icon: Icons.bolt_rounded, onPressed: _noop),
      ],
    );
  }

  static void _noop() {}
}

class _RecipeGrid extends ConsumerWidget {
  const _RecipeGrid();

  static const _recipes = [
    ('auto-pause', 'Auto-pause underperformers', 'Pause campaigns when CPA exceeds target for 72h.', Icons.pause_circle_rounded, AppColors.mythrixAmber),
    ('creative-refresh', 'Always-on creative refresh', 'Generate 3 new ad variants every 14 days.', Icons.refresh_rounded, AppColors.mythrixCyan),
    ('neg-keywords', 'Negative keyword harvester', 'Surface wasteful terms and exclude weekly.', Icons.block_flipped, AppColors.danger),
    ('lead-slack', 'Lead → Slack', 'Ping #sales when a hot lead enters CRM.', Icons.notifications_active_rounded, AppColors.mythrixMagenta),
    ('daily-briefing', 'Daily AI briefing', 'Email a 1-page summary every morning at 7am.', Icons.coffee_rounded, AppColors.mythrixCoral),
    ('bid-optimizer', 'Bid optimizer', 'Adjust bids hourly based on conversion probability.', Icons.tune_rounded, AppColors.mythrixViolet),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(automationsProvider);
    final activeIds = {for (final a in active) a.recipeId};
    final cols = MediaQuery.sizeOf(context).width >= 1280
        ? 3
        : (MediaQuery.sizeOf(context).width >= 800 ? 2 : 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recipes',
          subtitle: active.isEmpty
              ? 'Tap any recipe to activate'
              : '${active.length} active · running on autopilot',
        ),
        GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 2.4,
          children: [
            for (final r in _recipes)
              _RecipeCard(
                recipeId: r.$1,
                title: r.$2,
                description: r.$3,
                icon: r.$4,
                color: r.$5,
                active: activeIds.contains(r.$1),
                runs: active
                        .where((a) => a.recipeId == r.$1)
                        .map((a) => a.runsToday)
                        .firstOrNull ??
                    0,
                onToggle: () => ref.read(automationsProvider.notifier).toggle(r.$1),
              ),
          ],
        ),
      ],
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipeId,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.active,
    required this.runs,
    required this.onToggle,
  });

  final String recipeId;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool active;
  final int runs;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      hoverable: true,
      onTap: onToggle,
      glowColor: active ? color : null,
      glowIntensity: active ? 0.3 : 0,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: active ? 0.30 : 0.16),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: color.withValues(alpha: active ? 0.6 : 0.3)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (active) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (active) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Running · $runs runs today',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveWorkflows extends StatelessWidget {
  const _ActiveWorkflows();

  static const _workflows = [
    ('Spend rebalancer', '14 runs · today', 'success'),
    ('Creative fatigue watcher', '6 runs · today', 'success'),
    ('Audience overlap reducer', '2 runs · today', 'warning'),
    ('Lead scoring (every 5m)', '288 runs · today', 'success'),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Active workflows', icon: Icons.bolt_rounded),
          for (final w in _workflows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: AppColors.mythrixViolet, size: 18),
                  AppSpacing.hGapSm,
                  Expanded(child: Text(w.$1, style: Theme.of(context).textTheme.titleSmall)),
                  Text(w.$2,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                          )),
                  AppSpacing.hGapMd,
                  StatusPill(
                    label: w.$3 == 'success' ? 'Healthy' : 'Attention',
                    tone: w.$3 == 'success' ? PillTone.success : PillTone.warning,
                    dense: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
