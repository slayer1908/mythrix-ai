import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_pill.dart';

class BrandAssetsScreen extends StatelessWidget {
  const BrandAssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(),
          AppSpacing.vGapXl,
          const _BrandVoice(),
          AppSpacing.vGapXl,
          const _Palette(),
          AppSpacing.vGapXl,
          const _AssetLibrary(),
          AppSpacing.vGapXxl,
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Brand Assets', style: Theme.of(context).textTheme.headlineLarge),
              AppSpacing.vGapXs,
              Text(
                'Your voice, palette, and creative library — enforced everywhere MYTHRIX generates.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
              ),
            ],
          ),
        ),
        const GradientButton(label: 'Upload', icon: Icons.upload_rounded, onPressed: _noop),
      ],
    );
  }

  static void _noop() {}
}

class _BrandVoice extends StatelessWidget {
  const _BrandVoice();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Brand voice',
            subtitle: 'Learned from your past 100 high-performing pieces',
            icon: Icons.record_voice_over_rounded,
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: const [
              StatusPill(label: 'Confident', tone: PillTone.brand),
              StatusPill(label: 'Direct', tone: PillTone.brand),
              StatusPill(label: 'Mildly irreverent', tone: PillTone.brand),
              StatusPill(label: 'Never corporate', tone: PillTone.brand),
              StatusPill(label: 'Numbers > adjectives', tone: PillTone.brand),
              StatusPill(label: 'Active voice', tone: PillTone.brand),
            ],
          ),
          AppSpacing.vGapMd,
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: const Text(
              '"Most teams ship campaigns. MYTHRIX ships outcomes. Same brief — 5× the throughput, half the spend."',
              style: TextStyle(fontStyle: FontStyle.italic, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _Palette extends StatelessWidget {
  const _Palette();
  static const _swatches = [
    ('Mythrix Violet', AppColors.mythrixViolet),
    ('Mythrix Cyan', AppColors.mythrixCyan),
    ('Mythrix Magenta', AppColors.mythrixMagenta),
    ('Mythrix Lime', AppColors.mythrixLime),
    ('Mythrix Amber', AppColors.mythrixAmber),
    ('Mythrix Coral', AppColors.mythrixCoral),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Palette', icon: Icons.palette_rounded),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final s in _swatches) _Swatch(name: s.$1, color: s.$2),
            ],
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          AppSpacing.vGapXs,
          Text(name, style: Theme.of(context).textTheme.labelMedium),
          Text(
            '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontFamily: 'monospace',
                ),
          ),
        ],
      ),
    );
  }
}

class _AssetLibrary extends StatelessWidget {
  const _AssetLibrary();

  @override
  Widget build(BuildContext context) {
    final cols = MediaQuery.sizeOf(context).width >= 1280 ? 6 : (MediaQuery.sizeOf(context).width >= 800 ? 4 : 2);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Asset library',
            subtitle: '142 assets · 8 categories',
            trailing: Builder(builder: (ctx) => TextButton(
              onPressed: () => Snack.info(ctx, 'A dedicated asset library lands in the next pass — use Creative Studio for now.'),
              child: const Text('Open all'),
            )),
          ),
          GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < cols * 2; i++)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.chartPalette[i % AppColors.chartPalette.length],
                        AppColors.chartPalette[(i + 2) % AppColors.chartPalette.length],
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
