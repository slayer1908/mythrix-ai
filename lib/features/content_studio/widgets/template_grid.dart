import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snack.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_header.dart';

class _Template {
  const _Template(this.title, this.subtitle, this.icon, this.color);
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class TemplateGrid extends StatelessWidget {
  const TemplateGrid({super.key});

  static const _templates = [
    _Template('Instagram carousel', '5-slide story arc', Icons.view_carousel_rounded, AppColors.mythrixMagenta),
    _Template('Google PMax assets', '15 headlines + 4 descriptions', Icons.search_rounded, AppColors.mythrixAmber),
    _Template('Meta video ad', '15s vertical hook → proof → CTA', Icons.movie_creation_rounded, AppColors.mythrixCyan),
    _Template('Cold email', '4-step nurture sequence', Icons.email_rounded, AppColors.mythrixCoral),
    _Template('Blog SEO', '1,500-word AEO/SEO post', Icons.article_rounded, AppColors.mythrixLime),
    _Template('LinkedIn thought leadership', '3 hooks for execs', Icons.work_rounded, AppColors.mythrixIndigo),
    _Template('TikTok script', '8-second hook + sound cue', Icons.music_note_rounded, AppColors.mythrixPink),
    _Template('Product page', 'H1 + 3 features + FAQ', Icons.shopping_bag_rounded, AppColors.mythrixViolet),
  ];

  @override
  Widget build(BuildContext context) {
    final cols = MediaQuery.sizeOf(context).width >= 1280 ? 4 : (MediaQuery.sizeOf(context).width >= 800 ? 3 : 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Starting points',
          subtitle: 'Templates calibrated by MYTHRIX research team',
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 2.1,
          children: [
            for (final t in _templates)
              GlassCard(
                hoverable: true,
                onTap: () => Snack.info(context, 'Template "${t.title}" — paste the prompt above to use this starting point.'),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: t.color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: t.color.withValues(alpha: 0.32)),
                      ),
                      child: Icon(t.icon, color: t.color, size: 20),
                    ),
                    AppSpacing.hGapSm,
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title,
                              style: Theme.of(context).textTheme.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          AppSpacing.vGapXs,
                          Text(
                            t.subtitle,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
