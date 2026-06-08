import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/brand_profile.dart';
import '../../data/providers/brand_profile_providers.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Notion-style workspace picker. Tap to open a dropdown of every brand
/// the user has set up, with "+ Add brand" at the bottom.
class BrandSwitcher extends ConsumerStatefulWidget {
  const BrandSwitcher({super.key});

  @override
  ConsumerState<BrandSwitcher> createState() => _BrandSwitcherState();
}

class _BrandSwitcherState extends ConsumerState<BrandSwitcher> {
  final _layerLink = LayerLink();
  OverlayEntry? _entry;

  void _toggle() {
    if (_entry != null) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    final overlay = Overlay.of(context);
    _entry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, 8),
            child: _BrandList(onClose: _close),
          ),
        ],
      ),
    );
    overlay.insert(_entry!);
  }

  void _close() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(brandProfileProvider);
    final colors = Theme.of(context).colorScheme;

    if (active == null) {
      // No brand yet — sidebar will show "Set up brand" elsewhere.
      return const SizedBox.shrink();
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: _toggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      active.accentColor,
                      active.accentColor.withValues(alpha: 0.7),
                    ]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    active.brandName.isNotEmpty ? active.brandName[0].toUpperCase() : 'M',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  active.brandName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                if (active.accountType == AccountType.agency) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'AGENCY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                Icon(Icons.unfold_more_rounded,
                    size: 14, color: colors.onSurface.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandList extends ConsumerWidget {
  const _BrandList({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brands = ref.watch(allBrandsProvider);
    final active = ref.watch(brandProfileProvider);
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320, maxHeight: 440),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Text(
                  'YOUR BRANDS',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
              for (final b in brands)
                _BrandRow(
                  brand: b,
                  isActive: b.id == active?.id,
                  onTap: () {
                    ref.read(brandProfileProvider.notifier).switchTo(b.id);
                    onClose();
                  },
                ),
              const Divider(height: 1),
              InkWell(
                onTap: () {
                  onClose();
                  // Send to onboarding wizard to set up a NEW brand.
                  context.go(AppRoutes.onboarding);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Icon(Icons.add_rounded, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Add a brand',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const Spacer(),
                      Text(
                        'New workspace',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.brand, required this.isActive, required this.onTap});
  final dynamic brand;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isActive ? AppColors.mythrixViolet.withValues(alpha: 0.08) : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  brand.accentColor,
                  brand.accentColor.withValues(alpha: 0.7),
                ]),
                borderRadius: BorderRadius.circular(7),
              ),
              alignment: Alignment.center,
              child: Text(
                brand.brandName.isNotEmpty ? brand.brandName[0].toUpperCase() : 'B',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(brand.brandName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(
                    brand.industry,
                    style: TextStyle(fontSize: 11, color: colors.onSurface.withValues(alpha: 0.55)),
                  ),
                ],
              ),
            ),
            if (isActive) const Icon(Icons.check_rounded, size: 16, color: AppColors.mythrixViolet),
          ],
        ),
      ),
    );
  }
}
