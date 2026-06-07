import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/user_account.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final mode = ref.watch(themeModeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineLarge),
          AppSpacing.vGapXl,
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Account', icon: Icons.person_outline_rounded),
                if (user != null) ...[
                  _SettingRow(label: 'Name', value: user.fullName),
                  _SettingRow(label: 'Email', value: user.email),
                  _SettingRow(label: 'Workspace', value: user.workspaceName),
                  _SettingRow(label: 'Role', value: user.role.displayName),
                ],
              ],
            ),
          ),
          AppSpacing.vGapLg,
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Appearance', icon: Icons.palette_outlined),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      const Expanded(child: Text('Theme')),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined), label: Text('Light')),
                          ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Dark')),
                        ],
                        selected: {mode},
                        showSelectedIcon: false,
                        onSelectionChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v.first),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGapLg,
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Security',
                  icon: Icons.shield_outlined,
                ),
                _SecurityRow(
                  label: 'Two-factor authentication',
                  value: 'Enabled · Authenticator app',
                  pill: const StatusPill(label: 'On', tone: PillTone.success, dense: true),
                ),
                _SecurityRow(
                  label: 'Biometric unlock',
                  value: 'Use Face ID / Touch ID to open MYTHRIX',
                  pill: const StatusPill(label: 'On', tone: PillTone.success, dense: true),
                ),
                _SecurityRow(
                  label: 'Active sessions',
                  value: '3 devices',
                  pill: const StatusPill(label: 'Review', tone: PillTone.info, dense: true),
                ),
                _SecurityRow(
                  label: 'API tokens',
                  value: 'Scoped, rotateable',
                  pill: const StatusPill(label: '2 active', tone: PillTone.neutral, dense: true),
                ),
              ],
            ),
          ),
          AppSpacing.vGapLg,
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Integrations',
                  subtitle: 'Connected accounts powering MYTHRIX',
                  icon: Icons.extension_outlined,
                ),
                for (final i in const [
                  ('Google Ads', AppColors.mythrixAmber, true),
                  ('Meta Business', AppColors.mythrixCyan, true),
                  ('LinkedIn Marketing', AppColors.mythrixIndigo, true),
                  ('TikTok Business', AppColors.mythrixPink, false),
                  ('HubSpot', AppColors.mythrixCoral, false),
                  ('Shopify', AppColors.mythrixLime, true),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: i.$2.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.link_rounded, size: 16),
                        ),
                        AppSpacing.hGapMd,
                        Expanded(child: Text(i.$1, style: Theme.of(context).textTheme.titleSmall)),
                        StatusPill(
                          label: i.$3 ? 'Connected' : 'Connect',
                          tone: i.$3 ? PillTone.success : PillTone.brand,
                          dense: true,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          AppSpacing.vGapLg,
          OutlinedButton.icon(
            onPressed: () async {
              await AuthService.instance.signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
          AppSpacing.vGapLg,
          Text(
            'MYTHRIX.AI v${AppConstants.appVersion}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
          ),
          AppSpacing.vGapXxl,
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.value});
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
            child: Text(label,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _SecurityRow extends StatelessWidget {
  const _SecurityRow({required this.label, required this.value, required this.pill});
  final String label;
  final String value;
  final Widget pill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleSmall),
                Text(value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                        )),
              ],
            ),
          ),
          pill,
        ],
      ),
    );
  }
}
