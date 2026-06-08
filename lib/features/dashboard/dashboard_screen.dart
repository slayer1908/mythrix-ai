import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/animated_entrance.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/services/auto_week_service.dart';
import '../../data/models/brand_profile.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/providers/brand_profile_providers.dart';
import 'widgets/autopilot_card.dart';
import 'widgets/channel_mix_chart.dart';
import 'widgets/insights_feed.dart';
import 'widgets/library_snapshot.dart';
import 'widgets/performance_chart.dart';
import 'widgets/sparkline.dart';
import 'widgets/top_campaigns_table.dart';
import 'widgets/upcoming_posts_strip.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final wide = MediaQuery.sizeOf(context).width > 1280;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer(
            builder: (context, ref, _) {
              final profile = ref.watch(brandProfileProvider);
              return _Header(
                name: user?.fullName ?? 'there',
                brandName: profile?.brandName,
                primaryGoal: profile?.primaryGoal,
                accountType: profile?.accountType,
              );
            },
          ),
          AppSpacing.vGapXl,
          const _KpiRow(),
          AppSpacing.vGapXl,
          const LibrarySnapshot(),
          AppSpacing.vGapXl,
          if (wide)
            const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: PerformanceChart()),
                  AppSpacing.hGapLg,
                  Expanded(flex: 2, child: ChannelMixChart()),
                ],
              ),
            )
          else
            Column(
              children: const [
                PerformanceChart(),
                AppSpacing.vGapLg,
                ChannelMixChart(),
              ],
            ),
          AppSpacing.vGapXl,
          if (wide)
            const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 2, child: AutopilotCard()),
                  AppSpacing.hGapLg,
                  Expanded(flex: 3, child: InsightsFeed()),
                ],
              ),
            )
          else
            Column(
              children: const [
                AutopilotCard(),
                AppSpacing.vGapLg,
                InsightsFeed(),
              ],
            ),
          AppSpacing.vGapXl,
          const TopCampaignsTable(),
          AppSpacing.vGapXl,
          const UpcomingPostsStrip(),
          AppSpacing.vGapXxl,
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({
    required this.name,
    this.brandName,
    this.primaryGoal,
    this.accountType,
  });
  final String name;
  final String? brandName;
  final String? primaryGoal;
  final AccountType? accountType;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String get _subtitle {
    final brand = brandName?.trim();
    final goal = primaryGoal?.toLowerCase();
    if (accountType == AccountType.agency) {
      if (brand == null || brand.isEmpty) {
        return "Here's what MYTHRIX did across your clients overnight.";
      }
      return "Here's what MYTHRIX did for $brand's clients overnight. Switch brand in the top-left.";
    }
    if (brand == null || brand.isEmpty) {
      return "Here's what MYTHRIX has been up to overnight.";
    }
    if (goal == null || goal.isEmpty) {
      return "Here's what MYTHRIX has been up to for $brand overnight.";
    }
    return "Here's what MYTHRIX did for $brand — focused on: $goal.";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting, ${name.split(' ').first}.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              AppSpacing.vGapXs,
              Text(
                _subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ),
        if (MediaQuery.sizeOf(context).width > 720) ...[
          OutlinedButton.icon(
            onPressed: () => context.go('/app/analytics'),
            icon: const Icon(Icons.insights_rounded, size: 16),
            label: const Text('View analytics'),
          ),
          AppSpacing.hGapSm,
          GradientButton(
            label: 'Run my week with MYTHRIX',
            icon: Icons.auto_awesome_rounded,
            onPressed: () => _runMyWeek(context, ref),
          ),
        ],
      ],
    );
  }

  Future<void> _runMyWeek(BuildContext context, WidgetRef ref) async {
    // Show progress dialog while Mythrix "thinks"
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _MythrixThinkingDialog(),
    );

    // Give the dialog a beat to render + feel like real work is happening
    await Future<void>.delayed(const Duration(milliseconds: 1600));

    final result = AutoWeekService.runWeek(ref);

    if (context.mounted) {
      Navigator.of(context).pop(); // dismiss thinking dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ Week queued — ${result.summary}'),
          duration: const Duration(seconds: 7),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              // Notification panel already shows the events; nothing else to do.
            },
          ),
        ),
      );
    }
  }
}

/// Spinner-ish dialog with a 4-step "Mythrix is thinking" cascade.
class _MythrixThinkingDialog extends StatefulWidget {
  const _MythrixThinkingDialog();

  @override
  State<_MythrixThinkingDialog> createState() => _MythrixThinkingDialogState();
}

class _MythrixThinkingDialogState extends State<_MythrixThinkingDialog>
    with TickerProviderStateMixin {
  static const _steps = [
    'Analyzing your brand voice…',
    'Drafting 5 posts tuned to your audience…',
    'Picking optimal post times per channel…',
    'Composing a follow-up email…',
  ];

  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  Future<void> _tick() async {
    for (var i = 0; i < _steps.length - 1; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 380));
      if (!mounted) return;
      setState(() => _index = i + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            AppSpacing.vGapMd,
            Text(
              'Mythrix is running your week',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            AppSpacing.vGapLg,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < _steps.length; i++)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: i <= _index ? 1.0 : 0.35,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          if (i < _index)
                            const Icon(Icons.check_circle_rounded,
                                size: 18, color: AppColors.success)
                          else if (i == _index)
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.mythrixViolet,
                                ),
                              ),
                            )
                          else
                            const Icon(Icons.circle_outlined,
                                size: 18, color: Colors.grey),
                          AppSpacing.hGapSm,
                          Text(_steps[i]),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    int columns;
    if (width >= 1400) {
      columns = 5;
    } else if (width >= 1100) {
      columns = 4;
    } else if (width >= 800) {
      columns = 3;
    } else if (width >= 520) {
      columns = 2;
    } else {
      columns = 1;
    }

    final kpis = <Widget>[
      KpiCard(
        label: 'Total revenue (30d)',
        value: '\$218,340',
        delta: '+24.6%',
        trend: TrendDirection.up,
        icon: Icons.payments_rounded,
        accent: AppColors.mythrixLime,
        sparkline: Sparkline(values: _seed(180000, 220000, 12), color: AppColors.mythrixLime),
      ),
      KpiCard(
        label: 'Ad spend',
        value: '\$48,210',
        delta: '+12.1%',
        trend: TrendDirection.up,
        icon: Icons.bolt_rounded,
        accent: AppColors.mythrixViolet,
        sparkline: Sparkline(values: _seed(38000, 50000, 14), color: AppColors.mythrixViolet),
      ),
      KpiCard(
        label: 'Blended ROAS',
        value: '4.52×',
        delta: '+0.8×',
        trend: TrendDirection.up,
        icon: Icons.trending_up_rounded,
        accent: AppColors.mythrixCyan,
        sparkline: Sparkline(values: _seed(3.4, 4.6, 9), color: AppColors.mythrixCyan),
      ),
      KpiCard(
        label: 'Conversions',
        value: '3,128',
        delta: '+18.4%',
        trend: TrendDirection.up,
        icon: Icons.task_alt_rounded,
        accent: AppColors.mythrixMagenta,
        sparkline: Sparkline(values: _seed(2200, 3300, 18), color: AppColors.mythrixMagenta),
      ),
      KpiCard(
        label: 'CAC',
        value: '\$15.41',
        delta: '-6.2%',
        trend: TrendDirection.down,
        icon: Icons.swap_horiz_rounded,
        accent: AppColors.mythrixCoral,
        sparkline: Sparkline(values: _seed(17.2, 15.1, 10), color: AppColors.mythrixCoral),
      ),
    ];

    // Aspect ratio is width/height. Lower number = taller cards.
    // KPI tile needs ~220 height for icon row + 32pt number + delta + sparkline.
    final aspect = columns >= 5
        ? 1.2
        : columns >= 3
            ? 1.35
            : columns >= 2
                ? 1.6
                : 2.2;

    // Stagger the cards in so they cascade rather than pop simultaneously.
    final animated = staggeredEntrances(kpis,
        stagger: const Duration(milliseconds: 70));

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.lg,
      crossAxisSpacing: AppSpacing.lg,
      childAspectRatio: aspect,
      children: animated,
    );
  }


  static List<double> _seed(double start, double end, int seedNoise) {
    final out = <double>[];
    const n = 14;
    final step = (end - start) / n;
    for (var i = 0; i < n; i++) {
      final wave = ((i * 73 + seedNoise * 17) % 7) - 3;
      out.add(start + step * i + wave * (step.abs() * 0.4));
    }
    return out;
  }
}
