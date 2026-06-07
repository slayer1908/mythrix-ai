import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/billing_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_pill.dart';

class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentPlanProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Plans & billing', style: Theme.of(context).textTheme.headlineLarge),
          AppSpacing.vGapXs,
          Text(
            'Pick the plan that matches your scale. Upgrade or cancel any time.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
          ),
          AppSpacing.vGapXl,
          LayoutBuilder(builder: (context, c) {
            final wide = c.maxWidth >= 980;
            final cards = BillingPlan.values
                .map((p) => _PlanCard(
                      plan: p,
                      isCurrent: p == current,
                      onSelect: () => _select(ref, context, p),
                    ))
                .toList();

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    Expanded(child: cards[i]),
                    if (i != cards.length - 1) const SizedBox(width: AppSpacing.md),
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  cards[i],
                  if (i != cards.length - 1) const SizedBox(height: AppSpacing.md),
                ],
              ],
            );
          }),
          AppSpacing.vGapXl,
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Need a custom quote?',
                  subtitle: 'For agencies and enterprise — we tailor pricing to your usage.',
                ),
                OutlinedButton.icon(
                  onPressed: () => Snack.info(context, 'Email hello@mythrix.ai to chat about enterprise pricing.'),
                  icon: const Icon(Icons.mail_outline_rounded, size: 16),
                  label: const Text('Talk to sales'),
                ),
              ],
            ),
          ),
          AppSpacing.vGapXxl,
        ],
      ),
    );
  }

  Future<void> _select(WidgetRef ref, BuildContext context, BillingPlan p) async {
    final billing = ref.read(billingServiceProvider);
    if (!billing.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Stripe not configured. Add STRIPE_PUBLISHABLE_KEY to .env to enable real checkout.'),
        ),
      );
      ref.read(currentPlanProvider.notifier).state = p;
      return;
    }
    await billing.startCheckout(p);
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isCurrent,
    required this.onSelect,
  });

  final BillingPlan plan;
  final bool isCurrent;
  final VoidCallback onSelect;

  bool get _isRecommended => plan == BillingPlan.growth;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: _isRecommended ? AppColors.mythrixViolet : null,
      glowIntensity: _isRecommended ? 0.4 : 0.0,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isRecommended)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: StatusPill(label: 'MOST POPULAR', tone: PillTone.brand, dense: true),
            ),
          Text(plan.displayName, style: Theme.of(context).textTheme.headlineSmall),
          AppSpacing.vGapXs,
          Text(plan.priceLabel,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          AppSpacing.vGapMd,
          for (final f in plan.features)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 16),
                  AppSpacing.hGapSm,
                  Expanded(child: Text(f, style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            ),
          AppSpacing.vGapLg,
          if (isCurrent)
            OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
              child: const Text('Current plan'),
            )
          else if (plan == BillingPlan.scale)
            OutlinedButton(
              onPressed: onSelect,
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
              child: const Text('Talk to sales'),
            )
          else
            GradientButton(
              label: plan == BillingPlan.free ? 'Stay on Free' : 'Choose ${plan.displayName}',
              expand: true,
              onPressed: onSelect,
            ),
        ],
      ),
    );
  }
}
