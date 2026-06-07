import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/app_notification.dart';
import '../../data/providers/brand_profile_providers.dart';
import '../../data/providers/notifications_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Bell icon with a small unread badge. Tap → opens the panel as an overlay.
class NotificationsBell extends ConsumerStatefulWidget {
  const NotificationsBell({super.key});

  @override
  ConsumerState<NotificationsBell> createState() => _NotificationsBellState();
}

class _NotificationsBellState extends ConsumerState<NotificationsBell> {
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
          // Backdrop to catch outside taps
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          // Anchored panel
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 8),
            child: _NotificationsPanel(onDismiss: _close),
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
    final unread = ref.watch(unreadNotificationsCountProvider);
    final profile = ref.watch(brandProfileProvider);
    final accent = profile?.accentColor ?? AppColors.mythrixViolet;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: _toggle,
            icon: Icon(
              unread > 0
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
            ),
          ),
          if (unread > 0)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Theme.of(context).colorScheme.surface, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.55),
                      blurRadius: 10,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  unread > 9 ? '9+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationsPanel extends ConsumerWidget {
  const _NotificationsPanel({required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380, maxHeight: 520),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (notifications.any((n) => !n.read))
                      TextButton(
                        onPressed: () => ref
                            .read(notificationsProvider.notifier)
                            .markAllRead(),
                        child: const Text('Mark all read'),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // List
              Flexible(
                child: notifications.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: colors.outline.withValues(alpha: 0.4),
                        ),
                        itemBuilder: (_, i) => _NotificationTile(
                          notification: notifications[i],
                          onTap: () {
                            final n = notifications[i];
                            ref
                                .read(notificationsProvider.notifier)
                                .markRead(n.id);
                            if (n.route != null) {
                              onDismiss();
                              context.go(n.route!);
                            }
                          },
                          onDismiss: () => ref
                              .read(notificationsProvider.notifier)
                              .dismiss(notifications[i].id),
                        ),
                      ),
              ),
              if (notifications.isNotEmpty) ...[
                const Divider(height: 1),
                InkWell(
                  onTap: () =>
                      ref.read(notificationsProvider.notifier).clearAll(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Center(
                      child: Text(
                        'Clear all',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${(d.inDays / 7).floor()}w ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(brandProfileProvider);
    final accent = profile?.accentColor ?? AppColors.mythrixViolet;
    final colors = Theme.of(context).colorScheme;
    final unread = !notification.read;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread ? accent.withValues(alpha: 0.06) : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(notification.kind.icon, size: 18, color: accent),
            ),
            AppSpacing.hGapSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                unread ? FontWeight.w700 : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  AppSpacing.vGapXs,
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurface.withValues(alpha: 0.75),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vGapXs,
                  Text(
                    '${notification.kind.label} · ${_ago(notification.createdAt)}',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.4,
                      color: colors.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              tooltip: 'Dismiss',
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 40,
            color: colors.onSurface.withValues(alpha: 0.3),
          ),
          AppSpacing.vGapSm,
          Text(
            'You\'re all caught up',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          AppSpacing.vGapXs,
          Text(
            'New activity from your campaigns, posts, and AI will show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
