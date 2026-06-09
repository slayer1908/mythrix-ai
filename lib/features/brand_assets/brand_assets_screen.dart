import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/brand_profile.dart';
import '../../data/providers/brand_profile_providers.dart';

/// Real Brand Assets screen — reads the active brand profile and lets the
/// user edit name, vibe, voice tags, audience, goal, industry. Saves
/// to Hive + Firestore via brandProfileProvider.
class BrandAssetsScreen extends ConsumerWidget {
  const BrandAssetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(brandProfileProvider);
    if (profile == null) {
      return _NoBrandYet();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandHero(profile: profile),
          AppSpacing.vGapXl,
          _BrandVoiceCard(profile: profile),
          AppSpacing.vGapLg,
          _VibeCard(profile: profile),
          AppSpacing.vGapLg,
          _DetailsCard(profile: profile),
          AppSpacing.vGapXl,
        ],
      ),
    );
  }
}

class _NoBrandYet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.brush_rounded, size: 56, color: AppColors.mythrixViolet),
              AppSpacing.vGapMd,
              Text('No brand set up yet', style: Theme.of(context).textTheme.titleLarge),
              AppSpacing.vGapSm,
              Text(
                'Set up your brand profile in onboarding so Mythrix knows your voice and audience.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHero extends ConsumerWidget {
  const _BrandHero({required this.profile});
  final BrandProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAgency = profile.accountType == AccountType.agency;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                profile.accentColor,
                profile.accentColor.withValues(alpha: 0.6),
              ]),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: profile.accentColor.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              profile.brandName.isNotEmpty
                  ? profile.brandName[0].toUpperCase()
                  : 'M',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          AppSpacing.hGapLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(profile.brandName,
                        style: Theme.of(context).textTheme.headlineMedium),
                    AppSpacing.hGapSm,
                    if (isAgency)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: const Text('AGENCY',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6)),
                      )
                    else
                      StatusPill(label: profile.industry, tone: PillTone.brand, dense: true),
                  ],
                ),
                AppSpacing.vGapXs,
                Text(
                  isAgency
                      ? 'Multi-client workspace. Add a brand per client from the top-left switcher.'
                      : 'Single brand workspace. Mythrix knows your voice and audience.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _editName(context, ref, profile),
            icon: const Icon(Icons.edit_rounded, size: 14),
            label: const Text('Edit name'),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context, WidgetRef ref, BrandProfile p) async {
    final ctrl = TextEditingController(text: p.brandName);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit brand name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Brand name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != p.brandName) {
      ref.read(brandProfileProvider.notifier).updateActive(p.copyWith(brandName: result));
      if (context.mounted) Snack.success(context, 'Brand name updated.');
    }
  }
}

class _BrandVoiceCard extends ConsumerWidget {
  const _BrandVoiceCard({required this.profile});
  final BrandProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Brand voice',
            subtitle: 'Tags Mythrix uses in every AI generation',
            icon: Icons.record_voice_over_rounded,
            trailing: TextButton.icon(
              onPressed: () => _editVoice(context, ref, profile),
              icon: const Icon(Icons.edit_rounded, size: 14),
              label: const Text('Edit'),
            ),
          ),
          if (profile.voiceTags.isEmpty)
            Text(
              'No voice tags yet — click Edit to add some.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final tag in profile.voiceTags)
                  StatusPill(label: tag, tone: PillTone.brand),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _editVoice(BuildContext context, WidgetRef ref, BrandProfile p) async {
    final selected = p.voiceTags.toSet();
    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Pick brand voice tags'),
          content: SizedBox(
            width: 460,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in kVoiceTagOptions)
                  FilterChip(
                    label: Text(tag),
                    selected: selected.contains(tag),
                    onSelected: (v) => setState(() {
                      if (v && selected.length < 5) selected.add(tag);
                      else if (!v) selected.remove(tag);
                    }),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ref.read(brandProfileProvider.notifier)
                    .updateActive(p.copyWith(voiceTags: selected.toList()));
                Navigator.pop(ctx);
                Snack.success(context, 'Voice tags saved.');
              },
              child: const Text('Save'),
            ),
          ],
        );
      }),
    );
  }
}

class _VibeCard extends ConsumerWidget {
  const _VibeCard({required this.profile});
  final BrandProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentVibe = kBrandVibes.firstWhere(
      (v) => v.color.value == profile.accentColor.value,
      orElse: () => const BrandVibe('Custom', 'Your color', AppColors.mythrixViolet),
    );
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Vibe + palette',
            subtitle: 'Tints buttons, KPIs, chat orb, notifications across the app',
            icon: Icons.palette_rounded,
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kBrandVibes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.sizeOf(context).width >= 1100 ? 4 : 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.8,
            ),
            itemBuilder: (_, i) {
              final v = kBrandVibes[i];
              final selected = v.label == currentVibe.label;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ref.read(brandProfileProvider.notifier)
                        .updateActive(profile.copyWith(accentColor: v.color));
                    Snack.success(context, '${v.label} vibe applied.');
                  },
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      gradient: selected
                          ? LinearGradient(colors: [
                              v.color.withValues(alpha: 0.18),
                              v.color.withValues(alpha: 0.04),
                            ])
                          : null,
                      border: Border.all(
                        color: selected ? v.color : Theme.of(context).colorScheme.outline,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: v.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpacing.hGapSm,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(v.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 13)),
                              Text(
                                v.tagline,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context).colorScheme.onSurface
                                        .withValues(alpha: 0.55)),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_circle_rounded, size: 16, color: v.color),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends ConsumerWidget {
  const _DetailsCard({required this.profile});
  final BrandProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Brand details',
            subtitle: 'These details feed every AI prompt',
            icon: Icons.info_outline_rounded,
          ),
          _DetailRow(
            label: 'Industry',
            value: profile.industry,
            onEdit: () => _editChoice(
              context, ref, profile,
              title: 'Industry',
              options: kIndustryOptions,
              current: profile.industry,
              apply: (v) => profile.copyWith(industry: v),
            ),
          ),
          _DetailRow(
            label: 'Target audience',
            value: profile.audience.isEmpty ? 'Not set' : profile.audience,
            onEdit: () => _editText(
              context, ref, profile,
              title: 'Target audience',
              current: profile.audience,
              hint: 'e.g. Coffee enthusiasts 28-45 who care about origin',
              apply: (v) => profile.copyWith(audience: v),
            ),
          ),
          _DetailRow(
            label: 'Primary goal',
            value: profile.primaryGoal.isEmpty ? 'Not set' : profile.primaryGoal,
            onEdit: () => _editChoice(
              context, ref, profile,
              title: 'Primary goal',
              options: kGoalOptions,
              current: profile.primaryGoal,
              apply: (v) => profile.copyWith(primaryGoal: v),
            ),
          ),
          _DetailRow(
            label: 'Account type',
            value: profile.accountType.label,
            onEdit: null, // Account type is set at signup; switch requires re-onboarding
          ),
        ],
      ),
    );
  }

  Future<void> _editChoice(
    BuildContext context, WidgetRef ref, BrandProfile p, {
    required String title,
    required List<String> options,
    required String current,
    required BrandProfile Function(String) apply,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Pick $title'),
        children: [
          for (final o in options)
            SimpleDialogOption(
              child: Row(
                children: [
                  Icon(
                    o == current
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: o == current ? AppColors.mythrixViolet : null,
                  ),
                  AppSpacing.hGapSm,
                  Text(o),
                ],
              ),
              onPressed: () => Navigator.pop(context, o),
            ),
        ],
      ),
    );
    if (result != null && result != current) {
      ref.read(brandProfileProvider.notifier).updateActive(apply(result));
      if (context.mounted) Snack.success(context, '$title updated.');
    }
  }

  Future<void> _editText(
    BuildContext context, WidgetRef ref, BrandProfile p, {
    required String title,
    required String current,
    required String hint,
    required BrandProfile Function(String) apply,
  }) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result != current) {
      ref.read(brandProfileProvider.notifier).updateActive(apply(result));
      if (context.mounted) Snack.success(context, '$title updated.');
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.onEdit});
  final String label;
  final String value;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 16),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
        ],
      ),
    );
  }
}
