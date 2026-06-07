import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snack.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/content_draft.dart';

class PromptComposer extends StatelessWidget {
  const PromptComposer({
    super.key,
    required this.type,
    required this.tone,
    required this.brand,
    required this.audience,
    required this.onType,
    required this.onTone,
    required this.onBrand,
    required this.onAudience,
    required this.onPrompt,
    required this.onSubmit,
    required this.loading,
  });

  final ContentType type;
  final ContentTone tone;
  final String brand;
  final String audience;
  final ValueChanged<ContentType> onType;
  final ValueChanged<ContentTone> onTone;
  final ValueChanged<String> onBrand;
  final ValueChanged<String> onAudience;
  final ValueChanged<String> onPrompt;
  final VoidCallback onSubmit;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Brief',
            subtitle: 'Tell MYTHRIX who, what, and why',
            icon: Icons.edit_note_rounded,
          ),
          Text('Content type', style: Theme.of(context).textTheme.labelMedium),
          AppSpacing.vGapXs,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final t in ContentType.values)
                FilterChip(
                  label: Text(t.displayName),
                  selected: type == t,
                  onSelected: (_) => onType(t),
                ),
            ],
          ),
          AppSpacing.vGapMd,
          Text('Tone', style: Theme.of(context).textTheme.labelMedium),
          AppSpacing.vGapXs,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final t in ContentTone.values)
                FilterChip(
                  label: Text(t.displayName),
                  selected: tone == t,
                  onSelected: (_) => onTone(t),
                ),
            ],
          ),
          AppSpacing.vGapMd,
          TextField(
            decoration: const InputDecoration(
              labelText: 'Brand voice (optional)',
              hintText: 'e.g. confident, mildly irreverent, never corporate',
              prefixIcon: Icon(Icons.record_voice_over_rounded),
            ),
            onChanged: onBrand,
          ),
          AppSpacing.vGapMd,
          TextField(
            decoration: const InputDecoration(
              labelText: 'Target audience',
              hintText: 'e.g. CMOs at \$50M+ DTC brands',
              prefixIcon: Icon(Icons.diversity_3_rounded),
            ),
            onChanged: onAudience,
          ),
          AppSpacing.vGapMd,
          TextField(
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'What do you want to say?',
              hintText: 'Paste a brief, a product description, or just a one-liner.',
              alignLabelWithHint: true,
            ),
            onChanged: onPrompt,
          ),
          AppSpacing.vGapLg,
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Snack.info(context, 'Re-run with last prompt + tone — wiring up next pass. For now, click Generate.'),
                  icon: const Icon(Icons.history_rounded, size: 16),
                  label: const Text('Re-run last'),
                ),
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: GradientButton(
                  label: 'Generate 3 variants',
                  icon: Icons.auto_awesome_rounded,
                  expand: true,
                  loading: loading,
                  onPressed: loading ? null : onSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
