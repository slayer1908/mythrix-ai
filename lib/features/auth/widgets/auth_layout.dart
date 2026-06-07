import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/aurora_background.dart';

/// Two-column layout for auth screens: marketing pane on the left for wide
/// screens, centered card for narrow screens. The aurora background runs full-bleed.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;

    return AuroraBackground(
      child: SafeArea(
        child: wide
            ? Row(
                children: [
                  const Expanded(child: _MarketingPane()),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: child,
                  ),
                ),
              ),
      ),
    );
  }
}

class _MarketingPane extends StatelessWidget {
  const _MarketingPane();

  @override
  Widget build(BuildContext context) {
    final muted = Colors.white.withValues(alpha: 0.72);
    final highlight = Colors.white.withValues(alpha: 0.92);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.huge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (b) => AppColors.brandGradient.createShader(b),
            child: Text(
              'Marketing\non autopilot.',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    height: 1.0,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          AppSpacing.vGapLg,
          Text(
            'MYTHRIX.AI is the autonomous marketing OS. Generate content, launch ads, optimize spend, and grow — across every channel, 24/7.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: muted, height: 1.5),
          ),
          AppSpacing.vGapXxl,
          _Bullet(label: 'AI content, creatives, and ads — out of one brain.', color: highlight),
          _Bullet(label: 'Auto-launch on Google, Meta, TikTok, LinkedIn.', color: highlight),
          _Bullet(label: 'Negative keywords + bid rules running 24/7.', color: highlight),
          _Bullet(label: 'Cross-channel attribution & live ROAS.', color: highlight),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.brandGradient,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Text(label, style: TextStyle(color: color, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
