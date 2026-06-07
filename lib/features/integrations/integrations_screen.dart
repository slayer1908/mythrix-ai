import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/integration.dart';
import '../../data/providers/integrations_providers.dart';

/// Mythrix Integrations Hub — every platform Mythrix plugs into, on one screen.
/// Cards show: brand color, name, tagline, status badge, phase, top features.
/// Filter by category. Connect/disconnect with a click (simulated until Phase 4
/// OAuth ships).
class IntegrationsScreen extends ConsumerStatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  ConsumerState<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends ConsumerState<IntegrationsScreen> {
  IntegrationCategory? _selectedCategory;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(integrationsProvider);
    final connectedCount = ref.watch(connectedIntegrationsCountProvider);

    final filtered = all.where((i) {
      if (_selectedCategory != null && i.category != _selectedCategory) return false;
      if (_search.isNotEmpty &&
          !i.name.toLowerCase().contains(_search.toLowerCase()) &&
          !i.tagline.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    final cols = MediaQuery.sizeOf(context).width >= 1280
        ? 3
        : MediaQuery.sizeOf(context).width >= 800
            ? 2
            : 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(connectedCount: connectedCount, totalCount: all.length),
          AppSpacing.vGapXl,
          _SearchAndFilter(
            search: _search,
            onSearch: (v) => setState(() => _search = v),
            selected: _selectedCategory,
            onSelected: (c) => setState(() => _selectedCategory = c),
          ),
          AppSpacing.vGapLg,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.55,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _IntegrationCard(integration: filtered[i]),
          ),
          AppSpacing.vGapXl,
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.connectedCount, required this.totalCount});
  final int connectedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Integrations Hub',
                  style: Theme.of(context).textTheme.headlineLarge),
              AppSpacing.vGapXs,
              Text(
                'Connect every platform Mythrix needs to run your marketing. '
                'One brain, every channel. $connectedCount of $totalCount platforms connected.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                '$connectedCount connected',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchAndFilter extends StatelessWidget {
  const _SearchAndFilter({
    required this.search,
    required this.onSearch,
    required this.selected,
    required this.onSelected,
  });

  final String search;
  final ValueChanged<String> onSearch;
  final IntegrationCategory? selected;
  final ValueChanged<IntegrationCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search Google Ads, HubSpot, Shopify, Slack…',
            prefixIcon: const Icon(Icons.search_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          onChanged: onSearch,
        ),
        AppSpacing.vGapMd,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _Chip(label: 'All', selected: selected == null, onTap: () => onSelected(null)),
              const SizedBox(width: 8),
              for (final c in IntegrationCategory.values) ...[
                _Chip(
                  label: c.label,
                  icon: c.icon,
                  selected: selected == c,
                  onTap: () => onSelected(c),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.brandGradient : null,
            color: selected ? null : Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: selected ? Colors.white : null),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : null,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntegrationCard extends ConsumerWidget {
  const _IntegrationCard({required this.integration});
  final Integration integration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: integration.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(integration.category.icon, color: integration.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(integration.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(integration.category.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                          letterSpacing: 0.3,
                        )),
                  ],
                ),
              ),
              _StatusBadge(status: integration.status),
            ],
          ),
          AppSpacing.vGapSm,
          Text(
            integration.tagline,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (integration.features.isNotEmpty) ...[
            AppSpacing.vGapSm,
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final f in integration.features.take(3))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      f,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Text(
                integration.phase,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
              const Spacer(),
              _ActionButton(integration: integration),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final IntegrationStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 9.5,
              color: status.color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends ConsumerWidget {
  const _ActionButton({required this.integration});
  final Integration integration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (integration.status == IntegrationStatus.connected) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          minimumSize: const Size(0, 28),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          ref.read(integrationsProvider.notifier).toggleConnection(integration.id);
          Snack.info(context, '${integration.name} disconnected.');
        },
        child: const Text('Disconnect'),
      );
    }
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: const Size(0, 28),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        backgroundColor: integration.color.withValues(alpha: 0.16),
        foregroundColor: integration.color,
      ),
      onPressed: () {
        ref.read(integrationsProvider.notifier).toggleConnection(integration.id);
        Snack.success(context,
            '${integration.name} marked connected. Real OAuth ships in ${integration.phase}.');
      },
      child: const Text('Connect'),
    );
  }
}
