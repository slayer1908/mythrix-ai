import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/audience.dart';
import '../../data/providers/audiences_providers.dart';

class AudiencesScreen extends ConsumerWidget {
  const AudiencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audiences = ref.watch(audiencesProvider);

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
                    Text('Audiences', style: Theme.of(context).textTheme.headlineLarge),
                    AppSpacing.vGapXs,
                    Text(
                      'Madgicx-style funnel clusters. Mythrix pre-builds cold prospecting, warm retargeting, hot intent, and retention audiences — push to any ad network with one click.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                    ),
                  ],
                ),
              ),
              GradientButton(
                label: 'Custom audience',
                icon: Icons.add_rounded,
                onPressed: () => Snack.info(context, 'Custom audience builder ships with the CRM sync in Phase 2.'),
              ),
            ],
          ),
          AppSpacing.vGapXl,
          if (audiences.isNotEmpty) ...[
            SectionHeader(
              title: 'Your active audiences',
              subtitle: '${audiences.length} segment${audiences.length == 1 ? '' : 's'} ready to push',
              icon: Icons.people_alt_rounded,
            ),
            for (final a in audiences) _AudienceRow(audience: a),
            AppSpacing.vGapXl,
          ],
          for (final stage in FunnelStage.values) ...[
            _StageHeader(stage: stage),
            AppSpacing.vGapSm,
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kAudienceTemplates.where((t) => t['stage'] == stage).length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.sizeOf(context).width >= 1280 ? 3 : (MediaQuery.sizeOf(context).width >= 800 ? 2 : 1),
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 2.4,
              ),
              itemBuilder: (_, i) {
                final stageTemplates = kAudienceTemplates.where((t) => t['stage'] == stage).toList();
                final t = stageTemplates[i];
                return _TemplateCard(
                  template: t,
                  onAdopt: () {
                    ref.read(audiencesProvider.notifier).add(
                          name: t['name'] as String,
                          kind: t['kind'] as AudienceKind,
                          stage: t['stage'] as FunnelStage,
                          size: t['size'] as int,
                          percentMatch: t['percentMatch'] as int,
                        );
                    Snack.success(context, '✓ Audience adopted. Push to any network from the card.');
                  },
                );
              },
            ),
            AppSpacing.vGapXl,
          ],
        ],
      ),
    );
  }
}

class _StageHeader extends StatelessWidget {
  const _StageHeader({required this.stage});
  final FunnelStage stage;

  Color get _color {
    switch (stage) {
      case FunnelStage.cold: return AppColors.info;
      case FunnelStage.warm: return AppColors.warning;
      case FunnelStage.hot: return AppColors.danger;
      case FunnelStage.retention: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
        AppSpacing.hGapSm,
        Text(stage.label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _AudienceRow extends ConsumerWidget {
  const _AudienceRow({required this.audience});
  final Audience audience;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.mythrixViolet.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.people_alt_rounded, color: AppColors.mythrixViolet),
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(audience.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Row(
                    children: [
                      Text('${audience.kind.label} · ${_fmt(audience.size)} reach · ${audience.stage.label}',
                          style: TextStyle(fontSize: 11, color: colors.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => Snack.info(context, 'Pushing "${audience.name}" to Meta Ads + Google Ads…'),
              icon: const Icon(Icons.send_rounded, size: 14),
              label: const Text('Push to networks'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: audience.active,
              onChanged: (_) => ref.read(audiencesProvider.notifier).toggleActive(audience.id),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              onPressed: () {
                ref.read(audiencesProvider.notifier).remove(audience.id);
                Snack.info(context, 'Audience removed.');
              },
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template, required this.onAdopt});
  final Map<String, dynamic> template;
  final VoidCallback onAdopt;

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final size = template['size'] as int;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      hoverable: true,
      onTap: onAdopt,
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
          AppSpacing.hGapSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                AppSpacing.vGapXs,
                Text(
                  '${_fmt(size)} reach · ${(template['kind'] as AudienceKind).label}',
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
                ),
              ],
            ),
          ),
          const Icon(Icons.add_rounded, size: 20, color: AppColors.mythrixViolet),
        ],
      ),
    );
  }
}
