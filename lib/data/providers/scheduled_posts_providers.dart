import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/hive_service.dart';

const _scheduledPostsKey = 'scheduler.posts.v1';

class SchedulerEntry {
  SchedulerEntry({
    required this.id,
    required this.body,
    required this.channels,
    required this.scheduledFor,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String body;
  final List<SocialChannel> channels;
  final DateTime scheduledFor;
  final DateTime createdAt;

  String get title {
    final firstLine = body.split('\n').first;
    return firstLine.length > 60
        ? '${firstLine.substring(0, 60)}…'
        : firstLine;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'body': body,
        'channels': channels.map((c) => c.name).toList(),
        'scheduledFor': scheduledFor.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  static SchedulerEntry fromMap(Map<dynamic, dynamic> m) => SchedulerEntry(
        id: m['id'] as String,
        body: m['body'] as String? ?? '',
        channels: ((m['channels'] as List?) ?? const [])
            .map((c) => SocialChannel.values.firstWhere(
                  (sc) => sc.name == c,
                  orElse: () => SocialChannel.instagram,
                ))
            .toList(),
        scheduledFor:
            DateTime.tryParse(m['scheduledFor'] as String? ?? '') ?? DateTime.now(),
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class SchedulerNotifier extends StateNotifier<List<SchedulerEntry>> {
  SchedulerNotifier() : super(_load()) {
    addListener((_) => _save());
  }

  final _uuid = const Uuid();

  static List<SchedulerEntry> _load() {
    try {
      final raw = HiveService.instance.cache.get(_scheduledPostsKey);
      if (raw is List) {
        return raw.map((e) => SchedulerEntry.fromMap(e as Map)).toList()
          ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
      }
    } catch (_) {}
    return [];
  }

  void _save() {
    try {
      HiveService.instance.cache.put(
        _scheduledPostsKey,
        state.map((e) => e.toMap()).toList(),
      );
    } catch (_) {}
  }

  String schedule({
    required String body,
    required List<SocialChannel> channels,
    required DateTime when,
  }) {
    final id = _uuid.v4();
    final entry = SchedulerEntry(
      id: id,
      body: body,
      channels: channels,
      scheduledFor: when,
    );
    state = [...state, entry]
      ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
    return id;
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  void clear() {
    state = [];
  }
}

final scheduledPostsProvider =
    StateNotifierProvider<SchedulerNotifier, List<SchedulerEntry>>(
        (_) => SchedulerNotifier());
