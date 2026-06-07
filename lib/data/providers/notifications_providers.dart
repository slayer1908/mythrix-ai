import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/hive_service.dart';
import '../models/app_notification.dart';

const _key = 'notifications.feed.v1';
const _maxStored = 100;

/// Persistent notification feed. Newest first.
class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super(_load()) {
    addListener((_) => _save());
  }

  final _uuid = const Uuid();

  static List<AppNotification> _load() {
    try {
      final raw = HiveService.instance.cache.get(_key);
      if (raw is List) {
        return raw
            .map((e) => AppNotification.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  void _save() {
    try {
      final encoded = state.take(_maxStored).map((n) => n.toMap()).toList();
      HiveService.instance.cache.put(_key, encoded);
    } catch (_) {}
  }

  /// Push a new notification to the top of the feed.
  void push({
    required NotificationKind kind,
    required String title,
    required String body,
    String? route,
  }) {
    final n = AppNotification(
      id: _uuid.v4(),
      kind: kind,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      route: route,
    );
    state = [n, ...state].take(_maxStored).toList();
  }

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(read: true) else n,
    ];
  }

  void markAllRead() {
    state = [for (final n in state) n.copyWith(read: true)];
  }

  void dismiss(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>(
        (ref) => NotificationsNotifier());

/// Convenience: unread count.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.read).length;
});
