import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/aurora_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';

class AutopilotCard extends StatefulWidget {
  const AutopilotCard({super.key});
  @override
  State<AutopilotCard> createState() => _AutopilotCardState();
}

class _AutopilotCardState extends State<AutopilotCard> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: const AuroraBackground(intensity: 0.55),
          ),
        ),
        GlassCard(
          tintOpacity: 0.32,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                  ),
                  AppSpacing.hGapSm,
                  const Expanded(
                    child: Text(
                      'MYTHRIX Auto-Pilot',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                  ),
                ],
              ),
              AppSpacing.vGapSm,
              Text(
                'MYTHRIX is autonomously optimizing your campaigns. Below is what it did in the last 24 hours.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 13, height: 1.5),
              ),
              AppSpacing.vGapLg,
              const _AutopilotStat(
                  label: 'Budget rebalances applied', value: '14', icon: Icons.tune_rounded),
              const _AutopilotStat(
                  label: 'Negative keywords added', value: '38', icon: Icons.block_flipped),
              const _AutopilotStat(
                  label: 'Creative variations spun up', value: '6', icon: Icons.auto_awesome_motion_rounded),
              const _AutopilotStat(
                  label: 'Audiences refreshed', value: '4', icon: Icons.diversity_3_rounded),
              const _AutopilotStat(
                  label: 'Spend saved', value: '\$1,820', icon: Icons.savings_rounded, accent: AppColors.success),
              AppSpacing.vGapMd,
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '6 actions awaiting your approval.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  AppSpacing.hGapSm,
                  GradientButton(
                    label: 'Review',
                    size: MythrixButtonSize.small,
                    onPressed: () => context.go('/app/automations'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AutopilotStat extends StatelessWidget {
  const _AutopilotStat({
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: accent ?? Colors.white70),
          AppSpacing.hGapSm,
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: accent ?? Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
