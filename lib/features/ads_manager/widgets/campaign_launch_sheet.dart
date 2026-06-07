import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/campaign.dart';
import '../../../data/providers/brand_profile_providers.dart';
import '../../../data/providers/campaigns_providers.dart';

class CampaignLaunchSheet extends ConsumerStatefulWidget {
  const CampaignLaunchSheet({super.key});
  @override
  ConsumerState<CampaignLaunchSheet> createState() => _CampaignLaunchSheetState();
}

class _CampaignLaunchSheetState extends ConsumerState<CampaignLaunchSheet> {
  int _step = 0;
  final Set<AdNetwork> _networks = {AdNetwork.googleAds, AdNetwork.metaAds};
  CampaignObjective _objective = CampaignObjective.sales;
  double _budget = 250;
  String _bidStrategy = 'Target ROAS';

  void _launch() {
    if (_networks.isEmpty) return;
    final profile = ref.read(brandProfileProvider);
    final brand = profile?.brandName ?? 'Untitled';
    final name = '$brand · ${_objective.displayName}';
    ref.read(campaignsStoreProvider.notifier).launch(
          name: name,
          networks: _networks.toList(),
          objective: _objective,
          dailyBudget: _budget,
          bidStrategy: _bidStrategy,
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🚀 Launched "$name" across ${_networks.length} network(s) at \$${_budget.toStringAsFixed(0)}/day',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          border: Border.all(color: scheme.outline),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: scheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: SectionHeader(
                title: 'Launch a campaign',
                subtitle: 'MYTHRIX will configure and optimize it automatically',
                trailing: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: _Stepper(active: _step),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: _stepBody(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(top: BorderSide(color: scheme.outline)),
              ),
              child: Row(
                children: [
                  if (_step > 0)
                    OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  if (_step < 3)
                    GradientButton(
                      label: 'Continue',
                      onPressed: () => setState(() => _step++),
                    )
                  else
                    GradientButton(
                      label: 'Launch with MYTHRIX',
                      icon: Icons.rocket_launch_rounded,
                      onPressed: _launch,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return _step0();
      case 1:
        return _step1();
      case 2:
        return _step2();
      default:
        return _step3();
    }
  }

  Widget _step0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Which networks?', style: Theme.of(context).textTheme.titleLarge),
        AppSpacing.vGapXs,
        Text(
          'Pick the platforms. MYTHRIX will tailor creative and bidding per network.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
        AppSpacing.vGapLg,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final n in AdNetwork.values)
              FilterChip(
                label: Text(n.displayName),
                selected: _networks.contains(n),
                onSelected: (v) => setState(() {
                  if (v) {
                    _networks.add(n);
                  } else {
                    _networks.remove(n);
                  }
                }),
              ),
          ],
        ),
      ],
    );
  }

  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Objective', style: Theme.of(context).textTheme.titleLarge),
        AppSpacing.vGapLg,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final o in CampaignObjective.values)
              ChoiceChip(
                label: Text(o.displayName),
                selected: _objective == o,
                onSelected: (_) => setState(() => _objective = o),
              ),
          ],
        ),
      ],
    );
  }

  Widget _step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget & bidding', style: Theme.of(context).textTheme.titleLarge),
        AppSpacing.vGapLg,
        Text('Daily budget — \$${_budget.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: _budget,
          min: 20,
          max: 5000,
          divisions: 100,
          label: '\$${_budget.toStringAsFixed(0)}',
          onChanged: (v) => setState(() => _budget = v),
        ),
        AppSpacing.vGapMd,
        DropdownButtonFormField<String>(
          value: _bidStrategy,
          decoration: const InputDecoration(labelText: 'Bid strategy'),
          items: const [
            DropdownMenuItem(value: 'Target ROAS', child: Text('Target ROAS')),
            DropdownMenuItem(value: 'Target CPA', child: Text('Target CPA')),
            DropdownMenuItem(value: 'Maximize conversions', child: Text('Maximize conversions')),
            DropdownMenuItem(value: 'Maximize clicks', child: Text('Maximize clicks')),
            DropdownMenuItem(value: 'Manual CPC', child: Text('Manual CPC')),
          ],
          onChanged: (v) => setState(() => _bidStrategy = v!),
        ),
        AppSpacing.vGapMd,
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.mythrixViolet.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.mythrixViolet.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.mythrixViolet, size: 18),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'MYTHRIX will auto-reallocate budget across networks daily based on live ROAS — no manual rebalancing required.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _step3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review & launch', style: Theme.of(context).textTheme.titleLarge),
        AppSpacing.vGapLg,
        _ReviewLine(label: 'Networks', value: _networks.map((n) => n.displayName).join(', ')),
        _ReviewLine(label: 'Objective', value: _objective.displayName),
        _ReviewLine(label: 'Daily budget', value: '\$${_budget.toStringAsFixed(0)}'),
        _ReviewLine(label: 'Bid strategy', value: _bidStrategy),
        _ReviewLine(label: 'MYTHRIX Auto-Pilot', value: 'On — full optimization'),
        AppSpacing.vGapLg,
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.success.withValues(alpha: 0.18),
              AppColors.mythrixCyan.withValues(alpha: 0.12),
            ]),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_rounded, color: AppColors.success),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Brand-safety checks complete. MYTHRIX is ready to launch and will hold for your final approval.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.active});
  final int active;
  static const _labels = ['Networks', 'Objective', 'Budget', 'Review'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: List.generate(_labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                color: i ~/ 2 < active
                    ? AppColors.mythrixViolet
                    : Theme.of(context).colorScheme.outline,
              ),
            );
          }
          final idx = i ~/ 2;
          final done = idx < active;
          final current = idx == active;
          final color = done || current
              ? AppColors.mythrixViolet
              : Theme.of(context).colorScheme.outline;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: current ? AppColors.mythrixViolet : Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check_rounded, size: 14, color: AppColors.mythrixViolet)
                      : Text(
                          '${idx + 1}',
                          style: TextStyle(
                            color: current ? Colors.white : color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _labels[idx],
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ReviewLine extends StatelessWidget {
  const _ReviewLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
