import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});
  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  bool _annual = true;

  @override
  Widget build(BuildContext context) {
    final cols = MediaQuery.sizeOf(context).width >= 1100 ? 3 : 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Text(
                  'Pick what fits',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.vGapXs,
                Text(
                  'Start free. Upgrade only when Mythrix is making you money.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.vGapLg,
                _BillingToggle(
                  annual: _annual,
                  onToggle: (v) => setState(() => _annual = v),
                ),
              ],
            ),
          ),
          AppSpacing.vGapXl,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
              childAspectRatio: cols == 1 ? 1.4 : 0.7,
              children: [
                _PlanCard(
                  name: 'Starter',
                  price: 0,
                  tagline: 'For freelancers + brand owners getting started',
                  highlight: false,
                  features: const [
                    '1 brand workspace',
                    'AI text + image (Pollinations, no key)',
                    'Multi-network ads simulator',
                    'Automation rules engine',
                    '40+ integration UIs',
                    'Up to 30 generated assets / month',
                    'Community support',
                  ],
                  cta: 'Free forever',
                  annual: _annual,
                ),
                _PlanCard(
                  name: 'Pro',
                  price: _annual ? 29 : 39,
                  tagline: 'For solo marketers running 2+ brands',
                  highlight: true,
                  features: const [
                    'Up to 5 brand workspaces',
                    'Premium AI (Claude/GPT-4) via your key',
                    'Real social publishing (when wired)',
                    'Real ad-platform OAuth (when wired)',
                    'Unlimited generated assets',
                    'Server-side conversion tracking',
                    'Priority support',
                    '14-day free trial',
                  ],
                  cta: 'Start free trial',
                  annual: _annual,
                ),
                _PlanCard(
                  name: 'Agency',
                  price: _annual ? 99 : 129,
                  tagline: 'For agencies + freelancers with clients',
                  highlight: false,
                  features: const [
                    'Unlimited client brands',
                    'White-label demo links (coming)',
                    'Team seats — bring up to 5 collaborators',
                    'Client reporting digests',
                    'Bulk ops across clients',
                    'Dedicated Slack channel',
                    'SLA support',
                  ],
                  cta: 'Talk to sales',
                  annual: _annual,
                ),
              ],
            ),
          ),
          AppSpacing.vGapXxl,
          _FAQ(),
        ],
      ),
    );
  }
}

class _BillingToggle extends StatelessWidget {
  const _BillingToggle({required this.annual, required this.onToggle});
  final bool annual;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(label: 'Monthly', active: !annual, onTap: () => onToggle(false)),
          _Pill(
            label: 'Annual — save 25%',
            active: annual,
            onTap: () => onToggle(true),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: active ? AppColors.brandGradient : null,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : null,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.price,
    required this.tagline,
    required this.highlight,
    required this.features,
    required this.cta,
    required this.annual,
  });
  final String name;
  final int price;
  final String tagline;
  final bool highlight;
  final List<String> features;
  final String cta;
  final bool annual;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          glowColor: highlight ? AppColors.mythrixViolet : null,
          glowIntensity: highlight ? 0.4 : 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800)),
              AppSpacing.vGapXs,
              Text(tagline,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
              AppSpacing.vGapLg,
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (price == 0)
                    Text('Free',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800))
                  else ...[
                    Text('\$',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                    Text('$price',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800)),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('/mo',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
                    ),
                  ],
                ],
              ),
              if (price > 0 && annual)
                Text(
                  'Billed annually — \$${price * 12}/year',
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
                ),
              AppSpacing.vGapLg,
              for (final f in features)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_rounded,
                          size: 16, color: AppColors.success),
                      AppSpacing.hGapSm,
                      Expanded(
                          child: Text(f,
                              style: const TextStyle(fontSize: 13, height: 1.4))),
                    ],
                  ),
                ),
              const Spacer(),
              AppSpacing.vGapLg,
              if (highlight)
                Builder(builder: (ctx) => GradientButton(
                  label: cta,
                  icon: Icons.bolt_rounded,
                  onPressed: () => Snack.info(ctx,
                      'Stripe billing wires up in Phase 1.7 — for now this is free.'),
                ))
              else
                Builder(builder: (ctx) => OutlinedButton(
                  onPressed: () => Snack.info(ctx,
                      price == 0
                          ? 'You\'re already on the free plan.'
                          : 'Stripe billing wires up next. Contact us if you want early access.'),
                  child: Text(cta),
                )),
            ],
          ),
        ),
        if (highlight)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Text('POPULAR',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.6)),
            ),
          ),
      ],
    );
  }
}

class _FAQ extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Column(
        children: [
          Text('Common questions',
              style: Theme.of(context).textTheme.headlineSmall),
          AppSpacing.vGapLg,
          for (final qa in const [
            ('Can I cancel anytime?',
                'Yes. One-click cancel from Billing settings, no questions asked. Your data stays available for 30 days after.'),
            ('What happens to my data on the free plan?',
                'Everything you create stays yours. Local + cloud sync are unlimited on every plan.'),
            ('Do I need my own AI API keys?',
                'No. Pollinations runs on Starter (free). Pro lets you paste OpenAI/Anthropic/Gemini keys for premium quality.'),
            ('When does real ad-platform OAuth ship?',
                'Phase 4 of the roadmap. We\'re prioritizing it once 10 marketers on Pro tell us which networks they need first.'),
            ('Agencies — can I white-label this?',
                'Agency-tier white-label is in active design. DM us if you need it shipped this quarter.'),
          ]) ...[
            ExpansionTile(
              title: Text(qa.$1,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              childrenPadding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(qa.$2,
                    style: TextStyle(
                        height: 1.5,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
