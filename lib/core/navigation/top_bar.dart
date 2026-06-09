import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/auth_providers.dart';
import '../../data/providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../../data/providers/plan_providers.dart';
import 'brand_switcher.dart';
import 'notifications_panel.dart';

class TopBar extends ConsumerWidget {
  const TopBar({super.key, required this.onOpenCommandPalette});
  final VoidCallback onOpenCommandPalette;

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mythrix keyboard shortcuts'),
        content: const SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HelpRow(keys: 'Cmd / Ctrl + K', desc: 'Open the command palette'),
              _HelpRow(keys: 'Click bell icon', desc: 'Open the notifications center'),
              _HelpRow(keys: 'Click chat orb', desc: 'Ask Mythrix anything'),
              _HelpRow(keys: '"Run my week"', desc: 'Mythrix auto-generates posts + email + schedules them'),
              _HelpRow(keys: 'Library → Export all', desc: 'Backup every artifact to clipboard as JSON'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          const BrandSwitcher(),
          AppSpacing.hGapSm,
          const _TrialBadge(),
          AppSpacing.hGapMd,
          Expanded(
            child: _SearchTrigger(onTap: onOpenCommandPalette),
          ),
          AppSpacing.hGapLg,
          _AiAutopilotChip(),
          AppSpacing.hGapMd,
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          const NotificationsBell(),
          IconButton(
            tooltip: 'Help & shortcuts',
            onPressed: () => _showHelp(context),
            icon: const Icon(Icons.help_outline_rounded),
          ),
          AppSpacing.hGapSm,
          if (user != null)
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                user.initials,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

/// Topbar pill that shows trial countdown or "Upgrade" CTA based on plan.
class _TrialBadge extends ConsumerWidget {
  const _TrialBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(userPlanProvider);

    if (plan.isOnTrial) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: () => context.go(AppRoutes.billing),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule_rounded, size: 12, color: AppColors.warning),
                const SizedBox(width: 5),
                Text(
                  '${plan.trialDaysLeft}d trial',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (plan.tier == PlanTier.starter) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: () => context.go(AppRoutes.pricing),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Upgrade',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Pro / Agency — silent
    return const SizedBox.shrink();
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.keys, required this.desc});
  final String keys;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Text(keys, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
          ),
          AppSpacing.hGapSm,
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _SearchTrigger extends StatefulWidget {
  const _SearchTrigger({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_SearchTrigger> createState() => _SearchTriggerState();
}

class _SearchTriggerState extends State<_SearchTrigger> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: _hover
                    ? AppColors.mythrixViolet.withValues(alpha: 0.4)
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                AppSpacing.hGapSm,
                Expanded(
                  child: Text(
                    'Search anything — or ask MYTHRIX…',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: const Text(
                    '⌘K',
                    style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AiAutopilotChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.mythrixViolet.withValues(alpha: 0.2),
            AppColors.mythrixCyan.withValues(alpha: 0.15),
          ],
        ),
        border: Border.all(color: AppColors.mythrixViolet.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.hGapXs,
          const Text(
            'Auto-pilot · ON',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
