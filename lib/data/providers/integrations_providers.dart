import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/hive_service.dart';
import '../models/integration.dart';

const _connectedKey = 'integrations.connected.v1';

class IntegrationsNotifier extends StateNotifier<List<Integration>> {
  IntegrationsNotifier() : super(_load()) {
    addListener((_) => _save());
  }

  static List<Integration> _load() {
    final saved = <String>{};
    try {
      final raw = HiveService.instance.cache.get(_connectedKey);
      if (raw is List) saved.addAll(raw.cast<String>());
    } catch (_) {}
    // Pollinations always connected (free AI).
    saved.add('pollinations');
    return [
      for (final i in kIntegrationCatalog)
        if (saved.contains(i.id))
          i.copyWith(status: IntegrationStatus.connected)
        else
          i,
    ];
  }

  void _save() {
    try {
      final ids = state
          .where((i) => i.status == IntegrationStatus.connected)
          .map((i) => i.id)
          .toList();
      HiveService.instance.cache.put(_connectedKey, ids);
    } catch (_) {}
  }

  void toggleConnection(String id) {
    state = [
      for (final i in state)
        if (i.id == id)
          i.copyWith(
            status: i.status == IntegrationStatus.connected
                ? IntegrationStatus.available
                : IntegrationStatus.connected,
          )
        else
          i,
    ];
  }
}

final integrationsProvider =
    StateNotifierProvider<IntegrationsNotifier, List<Integration>>(
        (_) => IntegrationsNotifier());

final connectedIntegrationsCountProvider = Provider<int>(
  (ref) => ref
      .watch(integrationsProvider)
      .where((i) => i.status == IntegrationStatus.connected)
      .length,
);
