import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/user_plan.dart';
import '../../data/providers/audiences_providers.dart';
import '../../data/providers/campaigns_providers.dart';
import '../../data/providers/gallery_providers.dart';
import '../../data/providers/plan_providers.dart';
import '../../data/providers/scheduled_posts_providers.dart';

/// Real billing screen. Shows current plan, usage vs limits, upgrade CTA,
/// trial countdown. Backed by Firestore so plan state survives across
/// devices.
class BillingRealScreen extends ConsumerWidget {
  const BillingRealScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(userPlanProvider);
    final limits = ref.watch(planLimitsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlanHero(plan: plan),
          AppSpacing.vGapXl,
          _UsageCard(limits: limits),
          AppSpacing.vGapLg,
          _FeaturesCard(limits: limits, tier: plan.tier),
          AppSpacing.vGapLg,
          if (plan.tier != PlanTier.agency) _UpgradeCard(currentTier: plan.tier),
          AppSpacing.vGapLg,
          if (plan.tier != PlanTier.starter) _DangerCard(plan: plan),
        ],
      ),
    );
  }
}

class _PlanHero extends ConsumerWidget {
  const _PlanHero({required this.plan});
  final UserPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tierColor = Color(plan.tier.colorValue);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      glowColor: tierColor,
      glowIntensity: 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Billing & Plan',
                  style: Theme.of(context).textTheme.headlineLarge),
              const Spacer(),
              if (plan.isOnTrial)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule_rounded, size: 14, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Text(
                        '${plan.trialDaysLeft} days left in trial',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          AppSpacing.vGapLg,
          Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [tierColor, tierColor.withValues(alpha: 0.7)]),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: tierColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  plan.tier == PlanTier.agency
                      ? Icons.workspaces_rounded
                      : plan.tier == PlanTier.pro
                          ? Icons.bolt_rounded
                          : Icons.flag_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              AppSpacing.hGapLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.tier.label,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800)),
                    AppSpacing.vGapXs,
                    Text(
                      plan.tier.tagline,
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                    if (plan.cancelAtPeriodEnd)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '⚠️ Cancelling at period end',
                          style: TextStyle(
                              color: AppColors.warning, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsageCard extends ConsumerWidget {
  const _UsageCard({required this.limits});
  final PlanLimits limits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesCount = ref.watch(galleryProvider).length;
    final postsCount = ref.watch(scheduledPostsProvider).length;
    final campaignsCount = ref.watch(campaignsStoreProvider).length;
    final audiencesCount = ref.watch(audiencesProvider).length;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Your usage this month',
            subtitle: 'Reset on the 1st of every month',
            icon: Icons.bar_chart_rounded,
          ),
          _UsageRow(
            label: 'Brands',
            used: 1, // TODO: read from allBrandsProvider
            limit: limits.maxBrands,
          ),
          _UsageRow(
            label: 'AI images',
            used: imagesCount,
            limit: limits.maxImagesPerMonth,
          ),
          _UsageRow(
            label: 'Scheduled posts',
            used: postsCount,
            limit: limits.maxScheduledPostsPerMonth,
          ),
          _UsageRow(
            label: 'Active campaigns',
            used: campaignsCount,
            limit: limits.maxCampaigns,
          ),
          _UsageRow(
            label: 'Audiences',
            used: audiencesCount,
            limit: 9999, // unlimited on every plan
          ),
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({required this.label, required this.used, required this.limit});
  final String label;
  final int used;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final unlimited = limit >= 9999;
    final progress = unlimited ? 0.05 : (used / limit).clamp(0.0, 1.0);
    final overLimit = !unlimited && used >= limit;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              Text(
                unlimited ? '$used · unlimited' : '$used / $limit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: overLimit
                      ? AppColors.danger
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(
                overLimit ? AppColors.danger : AppColors.mythrixViolet,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesCard extends StatelessWidget {
  const _FeaturesCard({required this.limits, required this.tier});
  final PlanLimits limits;
  final PlanTier tier;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'What\'s included',
            subtitle: 'Features unlocked at your tier',
            icon: Icons.workspace_premium_rounded,
          ),
          _FeatureRow('Premium AI (Claude, GPT-4)', limits.premiumAIAllowed),
          _FeatureRow('Real social publishing (Instagram, LinkedIn, X)', limits.realPublishingEnabled),
          _FeatureRow('Real ad platform OAuth (Google, Meta, TikTok)', limits.realAdOAuthEnabled),
          _FeatureRow('${limits.teamSeats} team seat${limits.teamSeats == 1 ? '' : 's'}', true),
          _FeatureRow('White-label demo links (Agency tier)', tier == PlanTier.agency),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow(this.label, this.enabled);
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle_rounded : Icons.lock_rounded,
            size: 16,
            color: enabled
                ? AppColors.success
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          AppSpacing.hGapSm,
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: enabled
                    ? null
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpgradeCard extends ConsumerWidget {
  const _UpgradeCard({required this.currentTier});
  final PlanTier currentTier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upgradeTier =
        currentTier == PlanTier.starter ? PlanTier.pro : PlanTier.agency;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.mythrixViolet.withValues(alpha: 0.15),
          AppColors.mythrixCyan.withValues(alpha: 0.05),
        ]),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.mythrixViolet.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          const Icon(Icons.rocket_launch_rounded,
              color: AppColors.mythrixViolet, size: 32),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade to ${upgradeTier.label}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                AppSpacing.vGapXs,
                Text(
                  upgradeTier == PlanTier.pro
                      ? 'Unlock premium AI, real social publishing, and 5 brands — 14-day free trial.'
                      : 'Unlimited client brands, white-label reports, team seats.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hGapMd,
          GradientButton(
            label: upgradeTier == PlanTier.pro ? 'Start trial' : 'Upgrade',
            icon: Icons.arrow_forward_rounded,
            onPressed: () async {
              await ref.read(userPlanProvider.notifier).startTrial(upgradeTier);
              if (context.mounted) {
                Snack.success(context,
                    upgradeTier == PlanTier.pro
                        ? '✨ Welcome to Pro — 14-day trial activated.'
                        : '✨ Upgraded to Agency. Real Stripe billing wires up next.');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DangerCard extends ConsumerWidget {
  const _DangerCard({required this.plan});
  final UserPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Manage subscription',
            subtitle: 'Cancel or downgrade — your data stays for 30 days',
            icon: Icons.settings_rounded,
          ),
          if (!plan.cancelAtPeriodEnd)
            OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Cancel subscription?'),
                    content: const Text(
                        'Your plan stays active until the end of the billing period. After that you\'ll be moved to the free Starter tier. Your data stays for 30 days.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Keep my plan')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                          child: const Text('Cancel anyway')),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(userPlanProvider.notifier).cancelAtPeriodEnd();
                  if (context.mounted) {
                    Snack.info(context,
                        'Subscription will cancel at period end.');
                  }
                }
              },
              icon: const Icon(Icons.cancel_outlined, size: 16),
              label: const Text('Cancel subscription'),
            )
          else
            Text(
              'Your subscription will end and you\'ll move back to Starter. Contact us if you change your mind.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          AppSpacing.vGapSm,
          TextButton.icon(
            onPressed: () => context.go(AppRoutes.pricing),
            icon: const Icon(Icons.compare_arrows_rounded, size: 16),
            label: const Text('Compare plans'),
          ),
        ],
      ),
    );
  }
}
