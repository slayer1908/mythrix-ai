import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_pill.dart';

class AutomationRulesPanel extends StatefulWidget {
  const AutomationRulesPanel({super.key});
  @override
  State<AutomationRulesPanel> createState() => _AutomationRulesPanelState();
}

class _AutomationRulesPanelState extends State<AutomationRulesPanel> {
  final _rules = <_Rule>[
    _Rule('Pause if CPA > \$25 for 3 days', true, 'Mediums spend, brand-safe'),
    _Rule('Increase budget 20% if ROAS > 4×', true, 'Run nightly, cap +50%'),
    _Rule('Refresh creative if CTR drops 30%', true, 'Generate 3 variants'),
    _Rule('Exclude audience overlap > 35%', false, 'Meta + LinkedIn'),
    _Rule('Pause underperforming keyword < 5 clicks', true, 'After 7 days'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Automation rules',
              subtitle: 'Active rules MYTHRIX runs on your behalf',
              icon: Icons.bolt_rounded,
              trailing: const GradientButton(
                label: 'New rule',
                icon: Icons.add_rounded,
                size: MythrixButtonSize.small,
                onPressed: _noop,
              ),
            ),
            for (var i = 0; i < _rules.length; i++) ...[
              _RuleRow(
                rule: _rules[i],
                onToggle: (v) => setState(() => _rules[i] = _rules[i].copyWith(enabled: v)),
              ),
              if (i != _rules.length - 1) const Divider(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  static void _noop() {}
}

class _Rule {
  _Rule(this.text, this.enabled, this.notes);
  final String text;
  final bool enabled;
  final String notes;
  _Rule copyWith({String? text, bool? enabled, String? notes}) =>
      _Rule(text ?? this.text, enabled ?? this.enabled, notes ?? this.notes);
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.rule, required this.onToggle});
  final _Rule rule;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.mythrixViolet.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(Icons.bolt_rounded, color: AppColors.mythrixViolet, size: 18),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rule.text, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(rule.notes,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                      )),
            ],
          ),
        ),
        if (rule.enabled)
          const StatusPill(label: 'Live', tone: PillTone.success, dense: true)
        else
          const StatusPill(label: 'Off', tone: PillTone.neutral, dense: true),
        AppSpacing.hGapSm,
        Switch.adaptive(value: rule.enabled, onChanged: onToggle),
      ],
    );
  }
}
