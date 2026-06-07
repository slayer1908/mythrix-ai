import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user_account.dart';
import '../../data/providers/auth_providers.dart';
import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/mythrix_logo.dart';
import 'nav_destinations.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({
    super.key,
    required this.location,
    required this.collapsed,
    required this.onToggleCollapse,
  });

  final String location;
  final bool collapsed;
  final VoidCallback onToggleCollapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final width = collapsed ? 80.0 : 268.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: Theme.of(context).colorScheme.outline)),
      ),
      child: Column(
        children: [
          _Header(collapsed: collapsed, onToggle: onToggleCollapse),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                for (final section in kNavSections) ...[
                  if (!collapsed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.xs,
                      ),
                      child: Text(
                        section.title.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.42),
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    )
                  else
                    const SizedBox(height: AppSpacing.sm),
                  for (final dest in section.destinations)
                    _NavItem(
                      destination: dest,
                      collapsed: collapsed,
                      selected: location.startsWith(dest.route),
                      onTap: () => context.go(dest.route),
                    ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          _UserFooter(collapsed: collapsed, user: user),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.collapsed, required this.onToggle});
  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: collapsed ? AppSpacing.sm : AppSpacing.lg,
        ),
        child: Row(
          mainAxisAlignment: collapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            MythrixLogo(size: 24, showWordmark: !collapsed),
            if (!collapsed)
              IconButton(
                onPressed: onToggle,
                tooltip: 'Collapse sidebar',
                icon: const Icon(Icons.menu_open_rounded, size: 20),
              )
            else
              IconButton(
                onPressed: onToggle,
                tooltip: 'Expand sidebar',
                icon: const Icon(Icons.menu_rounded, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.destination,
    required this.collapsed,
    required this.selected,
    required this.onTap,
  });
  final NavDestination destination;
  final bool collapsed;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.65);
    final activeColor = AppColors.mythrixViolet;

    final bg = widget.selected
        ? activeColor.withValues(alpha: 0.14)
        : _hover
            ? scheme.surfaceContainerHigh
            : Colors.transparent;
    final fg = widget.selected ? activeColor : (muted);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 0 : AppSpacing.sm,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: widget.selected
                  ? Border.all(color: activeColor.withValues(alpha: 0.25))
                  : null,
            ),
            child: Tooltip(
              message: widget.collapsed ? widget.destination.label : '',
              child: Row(
                mainAxisAlignment: widget.collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    widget.selected
                        ? widget.destination.activeIcon
                        : widget.destination.icon,
                    color: fg,
                    size: 20,
                  ),
                  if (!widget.collapsed) ...[
                    AppSpacing.hGapSm,
                    Expanded(
                      child: Text(
                        widget.destination.label,
                        style: TextStyle(
                          color: fg,
                          fontSize: 14,
                          fontWeight:
                              widget.selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.destination.badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          widget.destination.badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      )
                    else if (widget.destination.shortcut != null && _hover)
                      Text(
                        widget.destination.shortcut!,
                        style: TextStyle(
                          color: muted.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserFooter extends ConsumerWidget {
  const _UserFooter({required this.collapsed, required this.user});
  final bool collapsed;
  final UserAccount? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final u = user;
    if (u == null) return const SizedBox.shrink();
    final initials = u.initials;
    final fullName = u.fullName;
    final workspace = u.workspaceName;

    return InkWell(
      onTap: () => context.go(AppRoutes.settings),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: collapsed
            ? Center(child: _Avatar(initials: initials))
            : Row(
                children: [
                  _Avatar(initials: initials),
                  AppSpacing.hGapSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          workspace,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await AuthService.instance.signOut();
                      if (context.mounted) context.go(AppRoutes.login);
                    },
                    tooltip: 'Sign out',
                    icon: const Icon(Icons.logout_rounded, size: 18),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}
