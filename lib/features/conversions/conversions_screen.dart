import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/conversion_event.dart';
import '../../data/providers/conversions_providers.dart';

class ConversionsScreen extends ConsumerWidget {
  const ConversionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(conversionsProvider);

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
                    Text('Conversions & Tracking', style: Theme.of(context).textTheme.headlineLarge),
                    AppSpacing.vGapXs,
                    Text(
                      'Tell every ad network what counts as success — and where to fire it. Server-side ready. GDPR-compliant. Built for iOS 17+ ATT and the post-cookie world.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                    ),
                  ],
                ),
              ),
              GradientButton(
                label: 'New conversion',
                icon: Icons.add_rounded,
                onPressed: () => _showBuilder(context, ref),
              ),
            ],
          ),
          AppSpacing.vGapXl,
          if (events.isNotEmpty) ...[
            SectionHeader(
              title: 'Tracked events',
              subtitle: '${events.length} event${events.length == 1 ? '' : 's'} firing across your networks',
              icon: Icons.track_changes_rounded,
            ),
            for (final e in events) _EventCard(event: e),
            AppSpacing.vGapXl,
          ],
          const SectionHeader(
            title: 'Quick-add standard events',
            subtitle: 'Pick from the canonical e-commerce + lead-gen library',
            icon: Icons.bolt_rounded,
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kStandardEvents.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.sizeOf(context).width >= 1100 ? 4 : 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 2.4,
            ),
            itemBuilder: (_, i) {
              final t = kStandardEvents[i];
              return _StandardEventCard(
                template: t,
                onAdd: () {
                  ref.read(conversionsProvider.notifier).add(
                        name: t['name'] as String,
                        platform: ConversionPlatform.ga4,
                        value: t['value'] as double,
                      );
                  Snack.success(context, '✓ ${t['name']} added & firing.');
                },
              );
            },
          ),
          AppSpacing.vGapXl,
          _PixelSetupCard(),
        ],
      ),
    );
  }

  Future<void> _showBuilder(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(context: context, builder: (_) => const _ConversionBuilderDialog());
  }
}

class _EventCard extends ConsumerWidget {
  const _EventCard({required this.event});
  final ConversionEvent event;

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
              color: event.enabled
                  ? AppColors.success.withValues(alpha: 0.15)
                  : colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.track_changes_rounded,
              color: event.enabled ? AppColors.success : colors.onSurface.withValues(alpha: 0.4),
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(event.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (event.serverSide) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.mythrixViolet.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text('SERVER-SIDE',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: AppColors.mythrixViolet)),
                      ),
                    ],
                  ],
                ),
                AppSpacing.vGapXs,
                Row(
                  children: [
                    Icon(Icons.account_tree_rounded, size: 11, color: colors.onSurface.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(event.platform.label,
                        style: TextStyle(fontSize: 11, color: colors.onSurface.withValues(alpha: 0.7))),
                    const SizedBox(width: 12),
                    Icon(Icons.attach_money_rounded, size: 11, color: colors.onSurface.withValues(alpha: 0.5)),
                    Text('${event.value.toStringAsFixed(2)} ${event.currency}',
                        style: TextStyle(fontSize: 11, color: colors.onSurface.withValues(alpha: 0.7))),
                    const SizedBox(width: 12),
                    Icon(Icons.schedule_rounded, size: 11, color: colors.onSurface.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(event.window.label,
                        style: TextStyle(fontSize: 11, color: colors.onSurface.withValues(alpha: 0.7))),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: event.enabled,
            onChanged: (_) => ref.read(conversionsProvider.notifier).toggleEnabled(event.id),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            onPressed: () {
              ref.read(conversionsProvider.notifier).remove(event.id);
              Snack.info(context, 'Conversion event removed.');
            },
          ),
        ],
      ),
      ),
    );
  }
}

class _StandardEventCard extends StatelessWidget {
  const _StandardEventCard({required this.template, required this.onAdd});
  final Map<String, dynamic> template;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onAdd,
      hoverable: true,
      child: Row(
        children: [
          Text(template['icon'] as String, style: const TextStyle(fontSize: 22)),
          AppSpacing.hGapSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('Default value: \$${(template['value'] as double).toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
              ],
            ),
          ),
          const Icon(Icons.add_rounded, size: 18, color: AppColors.mythrixViolet),
        ],
      ),
    );
  }
}

class _PixelSetupCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.code_rounded, color: Colors.white, size: 18),
              ),
              AppSpacing.hGapSm,
              Text('Pixel & server-side setup', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          AppSpacing.vGapMd,
          Text(
            'Mythrix installs and manages every tracking layer for you — Meta Pixel + CAPI, GA4 + Measurement Protocol, TikTok Events API, LinkedIn Insight, Pinterest Conversions, and your own server. iOS 17+ ATT compliant, GDPR consent-mode aware.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
          AppSpacing.vGapMd,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final layer in const [
                ('Client-side pixel', AppColors.success),
                ('Server-side CAPI', AppColors.mythrixViolet),
                ('Consent Mode v2', AppColors.info),
                ('Enhanced Conversions', AppColors.success),
                ('Offline conversions', AppColors.warning),
                ('First-party data', AppColors.mythrixCyan),
              ])
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: layer.$2.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    layer.$1,
                    style: TextStyle(
                      color: layer.$2,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConversionBuilderDialog extends ConsumerStatefulWidget {
  const _ConversionBuilderDialog();
  @override
  ConsumerState<_ConversionBuilderDialog> createState() => _ConversionBuilderDialogState();
}

class _ConversionBuilderDialogState extends ConsumerState<_ConversionBuilderDialog> {
  final _nameCtrl = TextEditingController();
  final _valueCtrl = TextEditingController(text: '25');
  ConversionPlatform _platform = ConversionPlatform.ga4;
  AttributionWindow _window = AttributionWindow.sevenDayClickOneDayView;
  bool _serverSide = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New conversion event', style: Theme.of(context).textTheme.headlineSmall),
              AppSpacing.vGapLg,
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Event name', border: OutlineInputBorder()),
              ),
              AppSpacing.vGapMd,
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _valueCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Value (\$)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  AppSpacing.hGapSm,
                  Expanded(
                    child: DropdownButtonFormField<ConversionPlatform>(
                      initialValue: _platform,
                      decoration: const InputDecoration(labelText: 'Platform', border: OutlineInputBorder()),
                      items: [
                        for (final p in ConversionPlatform.values)
                          DropdownMenuItem(value: p, child: Text(p.label, overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (v) => setState(() => _platform = v ?? ConversionPlatform.ga4),
                    ),
                  ),
                ],
              ),
              AppSpacing.vGapMd,
              DropdownButtonFormField<AttributionWindow>(
                initialValue: _window,
                decoration: const InputDecoration(labelText: 'Attribution window', border: OutlineInputBorder()),
                items: [
                  for (final w in AttributionWindow.values)
                    DropdownMenuItem(value: w, child: Text(w.label)),
                ],
                onChanged: (v) => setState(() => _window = v ?? AttributionWindow.sevenDayClickOneDayView),
              ),
              AppSpacing.vGapMd,
              SwitchListTile(
                title: const Text('Server-side firing'),
                subtitle: const Text('More accurate post-iOS 17 ATT, GDPR-safe'),
                value: _serverSide,
                onChanged: (v) => setState(() => _serverSide = v),
              ),
              AppSpacing.vGapMd,
              Row(
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  const Spacer(),
                  GradientButton(
                    label: 'Add event',
                    icon: Icons.check_rounded,
                    onPressed: () {
                      final name = _nameCtrl.text.trim().isEmpty ? 'Untitled conversion' : _nameCtrl.text.trim();
                      final value = double.tryParse(_valueCtrl.text) ?? 0;
                      ref.read(conversionsProvider.notifier).add(
                            name: name,
                            platform: _platform,
                            value: value,
                            window: _window,
                            serverSide: _serverSide,
                          );
                      Navigator.pop(context);
                      Snack.success(context, '✓ Conversion "$name" is firing.');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
