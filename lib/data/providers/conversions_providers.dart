import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/hive_service.dart';
import '../models/conversion_event.dart';

const _key = 'conversions.events.v1';

class ConversionsNotifier extends StateNotifier<List<ConversionEvent>> {
  ConversionsNotifier() : super(_load()) {
    addListener((_) => _save());
  }

  final _uuid = const Uuid();

  static List<ConversionEvent> _load() {
    try {
      final raw = HiveService.instance.cache.get(_key);
      if (raw is List) {
        return raw.map((e) => ConversionEvent.fromMap(e as Map)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (_) {}
    return [];
  }

  void _save() {
    try {
      HiveService.instance.cache.put(_key, state.map((e) => e.toMap()).toList());
    } catch (_) {}
  }

  String add({
    required String name,
    required ConversionPlatform platform,
    required double value,
    AttributionWindow window = AttributionWindow.sevenDayClickOneDayView,
    bool serverSide = false,
  }) {
    final id = _uuid.v4();
    state = [
      ConversionEvent(
        id: id,
        name: name,
        platform: platform,
        value: value,
        window: window,
        serverSide: serverSide,
      ),
      ...state,
    ];
    return id;
  }

  void toggleEnabled(String id) {
    state = [
      for (final e in state)
        if (e.id == id)
          (ConversionEvent(
            id: e.id, name: e.name, platform: e.platform, value: e.value,
            window: e.window, currency: e.currency, enabled: !e.enabled,
            serverSide: e.serverSide, createdAt: e.createdAt,
            firedCount: e.firedCount, lastFiredAt: e.lastFiredAt,
          ))
        else
          e,
    ];
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

final conversionsProvider =
    StateNotifierProvider<ConversionsNotifier, List<ConversionEvent>>(
        (_) => ConversionsNotifier());
