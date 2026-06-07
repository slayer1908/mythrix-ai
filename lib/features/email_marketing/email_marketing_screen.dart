import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/providers/email_campaigns_providers.dart';

class EmailMarketingScreen extends ConsumerWidget {
  const EmailMarketingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yours = ref.watch(emailCampaignsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(),
          AppSpacing.vGapXl,
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width >= 1280 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
            childAspectRatio: 1.5,
            children: const [
              KpiCard(label: 'Subscribers', value: '184,201', delta: '+2.1%', trend: TrendDirection.up, icon: Icons.group_rounded, accent: AppColors.mythrixCyan),
              KpiCard(label: 'Open rate', value: '38.4%', delta: '+1.8pp', trend: TrendDirection.up, icon: Icons.mark_email_read_rounded, accent: AppColors.mythrixLime),
              KpiCard(label: 'Click rate', value: '6.2%', delta: '+0.4pp', trend: TrendDirection.up, icon: Icons.touch_app_rounded, accent: AppColors.mythrixViolet),
              KpiCard(label: 'Revenue / send', value: '\$0.47', delta: '+\$0.06', trend: TrendDirection.up, icon: Icons.payments_rounded, accent: AppColors.mythrixAmber),
            ],
          ),
          AppSpacing.vGapXl,
          if (yours.isNotEmpty) ...[
            _YourCampaigns(campaigns: yours),
            AppSpacing.vGapXl,
          ],
          const _Sequences(),
          AppSpacing.vGapXl,
          const _RecentSends(),
          AppSpacing.vGapXxl,
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email Marketing',
                  style: Theme.of(context).textTheme.headlineLarge),
              AppSpacing.vGapXs,
              Text(
                'Sequences, broadcasts, and behavior-triggered flows.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.65),
                    ),
              ),
            ],
          ),
        ),
        GradientButton(
          label: 'New campaign',
          icon: Icons.add_rounded,
          onPressed: () => _showNewCampaignSheet(context, ref),
        ),
      ],
    );
  }

  Future<void> _showNewCampaignSheet(BuildContext context, WidgetRef ref) async {
    final subjectCtrl = TextEditingController();
    final previewCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final recipientsCtrl = TextEditingController(text: '5000');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.xl,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('New email campaign',
                    style: Theme.of(ctx).textTheme.headlineSmall),
                AppSpacing.vGapMd,
                TextField(
                  controller: subjectCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Subject line',
                    hintText: '☕ Early access opens Friday',
                  ),
                ),
                AppSpacing.vGapSm,
                TextField(
                  controller: previewCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Preview text',
                    hintText: 'A quick note before the doors open…',
                  ),
                ),
                AppSpacing.vGapSm,
                TextField(
                  controller: bodyCtrl,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Body',
                    alignLabelWithHint: true,
                  ),
                ),
                AppSpacing.vGapSm,
                TextField(
                  controller: recipientsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Recipients',
                    hintText: '5000',
                  ),
                ),
                AppSpacing.vGapLg,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ),
                    AppSpacing.hGapSm,
                    Expanded(
                      child: GradientButton(
                        label: 'Save campaign',
                        icon: Icons.send_rounded,
                        onPressed: () {
                          if (subjectCtrl.text.trim().isEmpty) return;
                          ref.read(emailCampaignsProvider.notifier).create(
                                subject: subjectCtrl.text.trim(),
                                preview: previewCtrl.text.trim(),
                                body: bodyCtrl.text.trim(),
                                recipientCount:
                                    int.tryParse(recipientsCtrl.text.trim()) ?? 0,
                              );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '✉️ Saved "${subjectCtrl.text.trim()}" — appears at the top of your campaigns'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _YourCampaigns extends ConsumerWidget {
  const _YourCampaigns({required this.campaigns});
  final List<EmailCampaign> campaigns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Your campaigns',
            subtitle:
                '${campaigns.length} campaign${campaigns.length == 1 ? '' : 's'} · saved to your device',
            icon: Icons.mail_outline_rounded,
          ),
          for (final c in campaigns)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        AppColors.mythrixViolet,
                        AppColors.mythrixCyan,
                      ]),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.alternate_email_rounded,
                        color: Colors.white),
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.subject,
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        if (c.preview.isNotEmpty)
                          Text(
                            c.preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.55),
                                    ),
                          ),
                        Text(
                          '${Fmt.compact(c.recipientCount)} recipients · ${Fmt.relative(c.createdAt)}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                        ),
                      ],
                    ),
                  ),
                  StatusPill(
                    label: c.status.name.toUpperCase(),
                    tone: c.status == EmailStatus.sent
                        ? PillTone.success
                        : (c.status == EmailStatus.scheduled
                            ? PillTone.info
                            : PillTone.neutral),
                    dense: true,
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.read(emailCampaignsProvider.notifier).remove(c.id),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Sequences extends StatelessWidget {
  const _Sequences();

  static const _seq = [
    ('Welcome — Day 0', 5, '\$32k', 'Active', AppColors.success),
    ('Cart abandonment — 3 emails', 3, '\$48k', 'Active', AppColors.success),
    ('Win-back — 90 days', 4, '\$12k', 'Active', AppColors.success),
    ('VIP upgrade — luxury tier', 6, '\$8k', 'Drafting', AppColors.warning),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Automated sequences',
            subtitle: 'Triggered flows running 24/7',
          ),
          for (final s in _seq)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.mythrixViolet, AppColors.mythrixCyan]),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(Icons.alt_route_rounded, color: Colors.white, size: 18),
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.$1, style: Theme.of(context).textTheme.titleSmall),
                        Text('${s.$2} emails',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                                )),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(s.$3, style: AppTypography.mono(weight: FontWeight.w700, color: AppColors.success)),
                      Text('attributed', style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                  AppSpacing.hGapMd,
                  StatusPill(label: s.$4, tone: s.$4 == 'Active' ? PillTone.success : PillTone.warning, dense: true),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentSends extends StatelessWidget {
  const _RecentSends();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Recent sends', subtitle: 'Broadcasts in the last 7 days'),
          for (final s in [
            ('Summer drop — sneak peek', '24,182 sent', '41.2%', '8.6%'),
            ('VIP early access', '4,201 sent', '52.8%', '14.2%'),
            ('Weekly digest #42', '38,440 sent', '33.6%', '4.8%'),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.$1, style: Theme.of(context).textTheme.titleSmall),
                        Text(s.$2,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                                )),
                      ],
                    ),
                  ),
                  Text('Open ${s.$3}',
                      style: AppTypography.mono(size: 12, color: AppColors.success)),
                  AppSpacing.hGapMd,
                  Text('Click ${s.$4}',
                      style: AppTypography.mono(size: 12, color: AppColors.mythrixViolet)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
