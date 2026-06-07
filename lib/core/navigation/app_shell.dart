import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/auth_providers.dart';
import '../../data/providers/chat_providers.dart';
import '../../data/providers/theme_provider.dart';
import '../../features/chat/chat_drawer.dart';
import '../../features/chat/chat_launcher.dart';
import '../extensions/context_extensions.dart';
import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../services/notification_bridge.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/mythrix_logo.dart';
import 'command_palette.dart';
import 'nav_destinations.dart';
import 'notifications_panel.dart';
import 'sidebar.dart';
import 'top_bar.dart';

/// The shell that wraps every authenticated route. On wide screens it shows a
/// persistent sidebar + top bar; on narrow screens it shows a bottom nav.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.location, required this.child});
  final String location;
  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _sidebarCollapsed = false;

  void _openCommandPalette() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Command Palette',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, __) => const CommandPalette(),
      transitionBuilder: (context, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
    );
  }

  int _mobileIndex() {
    for (var i = 0; i < kMobilePrimary.length; i++) {
      if (widget.location.startsWith(kMobilePrimary[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final chatOpen = ref.watch(chatDrawerOpenProvider);

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _openCommandPalette,
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _openCommandPalette,
      },
      child: Focus(
        autofocus: true,
        child: NotificationBridge(
          child: Scaffold(
          backgroundColor: context.colors.surfaceContainerLowest,
          body: Stack(
            children: [
              // Main app surface
              Positioned.fill(
                child: wide
                    ? _buildWideLayout(context)
                    : _buildNarrowLayout(context),
              ),

              // Dim backdrop when chat is open (tap to dismiss)
              if (chatOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => ref
                        .read(chatDrawerOpenProvider.notifier)
                        .state = false,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                  ),
                ),

              // Sliding chat drawer (right side)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                top: 0,
                bottom: wide ? 0 : 80,
                right: chatOpen ? 0 : -480,
                child: const ChatDrawer(),
              ),

              // Floating launcher (always bottom-right when chat is closed)
              Positioned(
                right: AppSpacing.lg,
                bottom: wide ? AppSpacing.lg : AppSpacing.lg + 76,
                child: const ChatLauncher(),
              ),
            ],
          ),
          bottomNavigationBar: wide ? null : _buildBottomNav(context),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Sidebar(
          location: widget.location,
          collapsed: _sidebarCollapsed,
          onToggleCollapse: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
        ),
        Expanded(
          child: Column(
            children: [
              TopBar(onOpenCommandPalette: _openCommandPalette),
              const Divider(height: 1),
              Expanded(
                child: ClipRect(
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _MobileTopBar(
            location: widget.location,
            onMenu: () => _showMobileMenu(context),
            onSearch: _openCommandPalette,
          ),
          const Divider(height: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final selected = _mobileIndex();
    return NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (i) => context.go(kMobilePrimary[i].route),
      destinations: kMobilePrimary
          .map(
            (d) => NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.activeIcon, color: AppColors.mythrixViolet),
              label: d.label,
            ),
          )
          .toList(),
    );
  }

  Future<void> _showMobileMenu(BuildContext context) async {
    final user = ref.read(currentUserProvider);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          children: [
            const MythrixLogo(size: 24),
            AppSpacing.vGapLg,
            if (user != null)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.mythrixViolet,
                  child: Text(user.initials, style: const TextStyle(color: Colors.white)),
                ),
                title: Text(user.fullName),
                subtitle: Text(user.workspaceName),
              ),
            AppSpacing.vGapMd,
            for (final section in kNavSections) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  section.title.toUpperCase(),
                  style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                        color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.5),
                        letterSpacing: 1.2,
                      ),
                ),
              ),
              for (final dest in section.destinations)
                ListTile(
                  leading: Icon(dest.icon),
                  title: Text(dest.label),
                  trailing: dest.badge != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            dest.badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go(dest.route);
                  },
                ),
            ],
            AppSpacing.vGapLg,
            const Divider(),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Toggle theme'),
              onTap: () {
                ref.read(themeModeProvider.notifier).toggle();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Sign out'),
              onTap: () async {
                Navigator.pop(ctx);
                await AuthService.instance.signOut();
                if (context.mounted) context.go(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileTopBar extends ConsumerWidget {
  const _MobileTopBar({
    required this.location,
    required this.onMenu,
    required this.onSearch,
  });

  final String location;
  final VoidCallback onMenu;
  final VoidCallback onSearch;

  String _titleForRoute() {
    for (final s in kNavSections) {
      for (final d in s.destinations) {
        if (location.startsWith(d.route)) return d.label;
      }
    }
    return 'MYTHRIX.AI';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(onPressed: onMenu, icon: const Icon(Icons.menu_rounded)),
          AppSpacing.hGapXs,
          Expanded(
            child: Text(
              _titleForRoute(),
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(onPressed: onSearch, icon: const Icon(Icons.search_rounded)),
          const NotificationsBell(),
        ],
      ),
    );
  }
}
