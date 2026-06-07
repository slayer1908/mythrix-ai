import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/automation_rule.dart';
import '../../data/providers/automation_rules_providers.dart';

/// Revealbot-style IF-THIS-THEN-THAT engine for ad campaigns.
class AutomationRulesScreen extends ConsumerWidget {
  const AutomationRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(automationRulesProvider);
    final active = ref.watch(activeRulesCountProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Automation Rules',
                        style: Theme.of(context).textTheme.headlineLarge),
                    AppSpacing.vGapXs,
                    Text(
                      'IF-THIS-THEN-THAT for your campaigns. Mythrix watches every metric 24/7 — when a trigger fires, the action runs automatically. $active rules active.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                    ),
                  ],
                ),
              ),
              GradientButton(
                label: 'New rule',
                icon: Icons.add_rounded,
                onPressed: () => _showBuilder(context, ref),
              ),
            ],
          ),
          AppSpacing.vGapXl,
          if (rules.isEmpty) _empty(context, ref),
          if (rules.isNotEmpty) ...[
            SectionHeader(
              title: 'Your rules',
              subtitle: '${rules.length} total · $active running',
              icon: Icons.bolt_rounded,
            ),
            for (final r in rules) _RuleCard(rule: r),
          ],
          AppSpacing.vGapXl,
          const SectionHeader(
            title: 'One-click templates',
            subtitle: 'Battle-tested rules used by top advertisers',
            icon: Icons.flash_on_rounded,
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kRuleTemplates.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.sizeOf(context).width >= 1100 ? 2 : 1,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 4.2,
            ),
            itemBuilder: (_, i) {
              final t = kRuleTemplates[i];
              return _TemplateCard(
                template: t,
                onAdopt: () {
                  ref.read(automationRulesProvider.notifier).add(
                        name: t['name'] as String,
                        trigger: t['trigger'] as RuleTrigger,
                        triggerValue: t['triggerValue'] as double,
                        action: t['action'] as RuleAction,
                        actionValue: t['actionValue'] as double?,
                      );
                  Snack.success(context, '✓ Rule adopted. Mythrix is now watching.');
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          const Icon(Icons.bolt_outlined, size: 56, color: AppColors.mythrixViolet),
          AppSpacing.vGapMd,
          Text('No rules yet', style: Theme.of(context).textTheme.titleLarge),
          AppSpacing.vGapXs,
          Text(
            'Pick a template below or build your own. Mythrix runs rules 24/7 so you never lose money to a bad ad set.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Future<void> _showBuilder(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _RuleBuilderDialog(),
    );
  }
}

class _RuleCard extends ConsumerWidget {
  const _RuleCard({required this.rule});
  final AutomationRule rule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: rule.enabled
                  ? AppColors.success.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: rule.enabled ? AppColors.success : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rule.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                AppSpacing.vGapXs,
                Text(
                  rule.summary,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                AppSpacing.vGapXs,
                Row(
                  children: [
                    Icon(Icons.refresh_rounded, size: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(
                      'Fired ${rule.timesFired}× ${rule.lastFiredAt != null ? "· last ${_ago(rule.lastFiredAt!)}" : ""}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: rule.enabled,
            onChanged: (_) {
              ref.read(automationRulesProvider.notifier).toggleEnabled(rule.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            onPressed: () {
              ref.read(automationRulesProvider.notifier).remove(rule.id);
              Snack.info(context, 'Rule removed.');
            },
          ),
        ],
      ),
      ),
    );
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template, required this.onAdopt});
  final Map<String, dynamic> template;
  final VoidCallback onAdopt;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppSpacing.hGapSm,
          OutlinedButton(
            onPressed: onAdopt,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 32),
            ),
            child: const Text('Adopt'),
          ),
        ],
      ),
    );
  }
}

class _RuleBuilderDialog extends ConsumerStatefulWidget {
  const _RuleBuilderDialog();
  @override
  ConsumerState<_RuleBuilderDialog> createState() => _RuleBuilderDialogState();
}

class _RuleBuilderDialogState extends ConsumerState<_RuleBuilderDialog> {
  final _nameCtrl = TextEditingController();
  final _triggerValueCtrl = TextEditingController(text: '1.3');
  final _actionValueCtrl = TextEditingController(text: '20');
  RuleTrigger _trigger = RuleTrigger.roasBelow;
  RuleAction _action = RuleAction.pause;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _triggerValueCtrl.dispose();
    _actionValueCtrl.dispose();
    super.dispose();
  }

  bool get _needsActionValue =>
      _action == RuleAction.increaseBudgetPct || _action == RuleAction.decreaseBudgetPct;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Build a rule', style: Theme.of(context).textTheme.headlineSmall),
              AppSpacing.vGapXs,
              Text(
                'IF a condition is met, THEN run an action automatically.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              AppSpacing.vGapLg,
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Rule name',
                  hintText: 'e.g. Pause underperforming Meta ads',
                  border: OutlineInputBorder(),
                ),
              ),
              AppSpacing.vGapMd,
              Text('WHEN', style: Theme.of(context).textTheme.labelLarge),
              AppSpacing.vGapXs,
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<RuleTrigger>(
                      initialValue: _trigger,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: [
                        for (final t in RuleTrigger.values)
                          DropdownMenuItem(value: t, child: Text(t.label, overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (v) => setState(() => _trigger = v ?? RuleTrigger.roasBelow),
                    ),
                  ),
                  AppSpacing.hGapSm,
                  Expanded(
                    child: TextField(
                      controller: _triggerValueCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        suffixText: _trigger.unit,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.vGapMd,
              Text('THEN', style: Theme.of(context).textTheme.labelLarge),
              AppSpacing.vGapXs,
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<RuleAction>(
                      initialValue: _action,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: [
                        for (final a in RuleAction.values)
                          DropdownMenuItem(value: a, child: Text(a.label, overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (v) => setState(() => _action = v ?? RuleAction.pause),
                    ),
                  ),
                  if (_needsActionValue) ...[
                    AppSpacing.hGapSm,
                    Expanded(
                      child: TextField(
                        controller: _actionValueCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          suffixText: '%',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              AppSpacing.vGapLg,
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  GradientButton(
                    label: 'Create rule',
                    icon: Icons.check_rounded,
                    onPressed: () {
                      final name = _nameCtrl.text.trim().isEmpty
                          ? 'Untitled rule'
                          : _nameCtrl.text.trim();
                      final tv = double.tryParse(_triggerValueCtrl.text) ?? 0;
                      final av = _needsActionValue
                          ? double.tryParse(_actionValueCtrl.text)
                          : null;
                      ref.read(automationRulesProvider.notifier).add(
                            name: name,
                            trigger: _trigger,
                            triggerValue: tv,
                            action: _action,
                            actionValue: av,
                          );
                      Navigator.pop(context);
                      Snack.success(context, '⚡ Rule created. Mythrix is now watching 24/7.');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
