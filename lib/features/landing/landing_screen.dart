import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/aurora_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/mythrix_logo.dart';
import '../../data/providers/waitlist_providers.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final _emailCtrl = TextEditingController();
  String? _msg;
  bool _success = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submitWaitlist() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() {
        _msg = 'Drop your email so we can let you in.';
        _success = false;
      });
      return;
    }
    final added = ref.read(waitlistProvider.notifier).add(email);
    setState(() {
      if (added) {
        _msg = "You're in. We'll DM you when your seat opens.";
        _success = true;
        _emailCtrl.clear();
      } else {
        _msg = 'That email is already on the list (or looks off).';
        _success = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(waitlistCountProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0B1E),
      body: Stack(
        children: [
          const Positioned.fill(child: AuroraBackground(intensity: 0.7)),
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 900),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    _Nav(),
                    AppSpacing.vGapXxl,
                    AppSpacing.vGapXxl,
                    _Hero(
                      count: count,
                      emailCtrl: _emailCtrl,
                      msg: _msg,
                      success: _success,
                      onSubmit: _submitWaitlist,
                    ),
                    AppSpacing.vGapXxl,
                    AppSpacing.vGapXxl,
                    const _FeatureGrid(),
                    AppSpacing.vGapXxl,
                    const _AgencyCallout(),
                    AppSpacing.vGapXxl,
                    const _SocialProof(),
                    AppSpacing.vGapXxl,
                    AppSpacing.vGapXxl,
                    const _Footer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Row(
          children: [
            const MythrixLogo(size: 28),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Sign in',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            AppSpacing.hGapSm,
            GradientButton(
              label: 'Try the demo',
              icon: Icons.bolt_rounded,
              onPressed: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.count,
    required this.emailCtrl,
    required this.msg,
    required this.success,
    required this.onSubmit,
  });
  final int count;
  final TextEditingController emailCtrl;
  final String? msg;
  final bool success;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count marketers on the waitlist · Limited beta',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.vGapLg,
            ShaderMask(
              shaderCallback: (bounds) => AppColors.brandGradient.createShader(bounds),
              child: const Text(
                'Marketing on autopilot.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                  height: 1.05,
                ),
              ),
            ),
            AppSpacing.vGapMd,
            const Text(
              'MYTHRIX.AI is the autonomous marketing OS. Generate content, launch ads,\noptimize spend, and grow — across every channel, 24/7.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                height: 1.5,
              ),
            ),
            AppSpacing.vGapXl,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: emailCtrl,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => onSubmit(),
                      decoration: InputDecoration(
                        hintText: 'you@brand.com',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                        prefixIcon: const Icon(Icons.mail_outline_rounded, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: const BorderSide(color: AppColors.mythrixViolet, width: 2),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.hGapSm,
                  GradientButton(
                    label: 'Get early access',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: onSubmit,
                  ),
                ],
              ),
            ),
            if (msg != null) ...[
              AppSpacing.vGapSm,
              Text(
                msg!,
                style: TextStyle(
                  color: success ? AppColors.success : Colors.amber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            AppSpacing.vGapSm,
            Builder(builder: (ctx) => TextButton.icon(
              onPressed: () => ctx.go('/login'),
              icon: const Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 18),
              label: const Text(
                'Or skip the line — try the live demo →',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            )),
          ],
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    final cols = MediaQuery.sizeOf(context).width >= 1100 ? 3 : (MediaQuery.sizeOf(context).width >= 700 ? 2 : 1);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Column(
          children: [
            const Text(
              'One brain. Every channel.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            AppSpacing.vGapSm,
            Text(
              'No more switching between Google Ads, Meta, HubSpot, Mailchimp, Slack.\nMythrix is the layer that runs them all for you.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16, height: 1.5),
            ),
            AppSpacing.vGapXl,
            GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.lg,
              crossAxisSpacing: AppSpacing.lg,
              childAspectRatio: 1.4,
              children: const [
                _Feature(
                  icon: Icons.auto_awesome_rounded,
                  title: 'AI content, drafted in your voice',
                  body: 'Onboarding captures your brand voice, audience, and goal. Every post, email, and ad is written in YOUR brand tone — not generic AI slop.',
                  color: AppColors.mythrixViolet,
                ),
                _Feature(
                  icon: Icons.campaign_rounded,
                  title: '11 ad networks. One pane.',
                  body: 'Google Ads, LSA, Meta, TikTok, LinkedIn, X, Microsoft, Reddit, Pinterest, Snap, Amazon DSP — each gets its own dedicated workspace.',
                  color: AppColors.mythrixCyan,
                ),
                _Feature(
                  icon: Icons.bolt_rounded,
                  title: 'Rules engine that runs 24/7',
                  body: 'IF ROAS drops below 1.3× THEN pause. IF CTR climbs 50% THEN scale +20%. Set it once. Sleep through the bad ad sets.',
                  color: AppColors.mythrixLime,
                ),
                _Feature(
                  icon: Icons.people_alt_rounded,
                  title: 'AI audience launcher',
                  body: 'Pre-built funnel clusters: cold prospecting, warm retargeting, hot intent, retention. Push to any network in one click.',
                  color: AppColors.mythrixAmber,
                ),
                _Feature(
                  icon: Icons.track_changes_rounded,
                  title: 'Server-side conversions',
                  body: 'GA4 + Meta CAPI + Google Ads GCLID + TikTok Events API. iOS 17 ATT + GDPR + Consent Mode v2 — built in, not bolted on.',
                  color: AppColors.mythrixMagenta,
                ),
                _Feature(
                  icon: Icons.bar_chart_rounded,
                  title: '"Run my week" button',
                  body: 'One click. Mythrix generates 5 brand-voice posts, picks optimal times per channel, drafts 1 email campaign — all queued in 1.6 seconds.',
                  color: AppColors.mythrixIndigo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.body, required this.color});
  final IconData icon;
  final String title, body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          AppSpacing.vGapMd,
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          AppSpacing.vGapXs,
          Expanded(
            child: Text(
              body,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgencyCallout extends StatelessWidget {
  const _AgencyCallout();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Text(
                        'FOR AGENCIES + FREELANCERS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    AppSpacing.vGapMd,
                    const Text(
                      'One Mythrix.\nUnlimited client brands.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                    AppSpacing.vGapMd,
                    Text(
                      'Manage 5, 15, or 50 client brands from a single workspace. Each client gets a dedicated voice, audience, palette, and reporting view. Switch between them with one click via the top-left brand picker.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 16,
                        height: 1.55,
                      ),
                    ),
                    AppSpacing.vGapLg,
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _AgencyChip(text: 'Notion-style brand switcher'),
                        _AgencyChip(text: 'Per-client AI voice'),
                        _AgencyChip(text: 'White-label reports (soon)'),
                        _AgencyChip(text: 'Team seats'),
                        _AgencyChip(text: 'Bulk ops'),
                      ],
                    ),
                  ],
                ),
              ),
              if (MediaQuery.sizeOf(context).width >= 900) ...[
                AppSpacing.hGapXl,
                Expanded(
                  flex: 2,
                  child: _AgencyMockBrands(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AgencyChip extends StatelessWidget {
  const _AgencyChip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, color: Colors.white, size: 13),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AgencyMockBrands extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const brands = [
      ('Brewline', 'E-commerce', AppColors.mythrixLime),
      ('Northwave', 'D2C', AppColors.mythrixCyan),
      ('Helios', 'B2B SaaS', AppColors.mythrixViolet),
      ('Mariposa', 'Hospitality', AppColors.mythrixCoral),
      ('Atlas Health', 'Healthcare', AppColors.mythrixIndigo),
    ];
    return Column(
      children: [
        for (final b in brands)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [b.$3, b.$3.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    b.$1[0],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(b.$1,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                      Text(b.$2,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white.withValues(alpha: 0.4), size: 16),
              ],
            ),
          ),
      ],
    );
  }
}

class _SocialProof extends StatelessWidget {
  const _SocialProof();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Column(
          children: [
            const Text(
              'Built for the marketers tired of switching tabs.',
              style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 0.5),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapLg,
            Wrap(
              spacing: 32, runSpacing: 18,
              alignment: WrapAlignment.center,
              children: const [
                _Logo(label: 'Google Ads'),
                _Logo(label: 'Meta'),
                _Logo(label: 'TikTok'),
                _Logo(label: 'LinkedIn'),
                _Logo(label: 'HubSpot'),
                _Logo(label: 'Shopify'),
                _Logo(label: 'Stripe'),
                _Logo(label: 'GA4'),
                _Logo(label: 'Slack'),
                _Logo(label: 'Notion'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.55),
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Column(
          children: [
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.12),
            ),
            AppSpacing.vGapLg,
            Row(
              children: [
                const MythrixLogo(size: 22),
                const Spacer(),
                Text(
                  '© 2026 MYTHRIX.AI — Marketing on autopilot',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
