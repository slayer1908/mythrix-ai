import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_pill.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  static const _members = [
    ('Maya Patel', 'maya@acme.co', 'Owner', AppColors.mythrixViolet),
    ('Diego Alvarez', 'diego@acme.co', 'Admin', AppColors.mythrixCyan),
    ('Sasha Kim', 'sasha@acme.co', 'Editor', AppColors.mythrixMagenta),
    ('Theo Brown', 'theo@acme.co', 'Analyst', AppColors.mythrixLime),
    ('Lena Cho', 'lena@acme.co', 'Viewer', AppColors.mythrixAmber),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Team', style: Theme.of(context).textTheme.headlineLarge),
                    AppSpacing.vGapXs,
                    Text(
                      'Members, roles, and audit log.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                    ),
                  ],
                ),
              ),
              const GradientButton(label: 'Invite', icon: Icons.person_add_rounded, onPressed: _noop),
            ],
          ),
          AppSpacing.vGapXl,
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'Members', subtitle: '${_members.length} active'),
                for (final m in _members)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [m.$4, m.$4.withValues(alpha: 0.6)]),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            m.$1.split(' ').map((s) => s[0]).join(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        AppSpacing.hGapMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.$1, style: Theme.of(context).textTheme.titleSmall),
                              Text(m.$2,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                                      )),
                            ],
                          ),
                        ),
                        StatusPill(label: m.$3, tone: PillTone.brand, dense: true),
                        AppSpacing.hGapSm,
                        Builder(builder: (ctx) => IconButton(
                          onPressed: () => Snack.info(ctx, 'Member actions (transfer role, deactivate, audit log) ship with multi-user auth in Phase 1.'),
                          icon: const Icon(Icons.more_horiz_rounded),
                        )),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          AppSpacing.vGapXxl,
        ],
      ),
    );
  }

  static void _noop() {}
}
