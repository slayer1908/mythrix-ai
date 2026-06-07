import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/hive_service.dart';
import '../models/audience.dart';

const _key = 'audiences.v1';

class AudiencesNotifier extends StateNotifier<List<Audience>> {
  AudiencesNotifier() : super(_load()) {
    addListener((_) => _save());
  }

  final _uuid = const Uuid();

  static List<Audience> _load() {
    try {
      final raw = HiveService.instance.cache.get(_key);
      if (raw is List) {
        return raw.map((e) => Audience.fromMap(e as Map)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (_) {}
    return [];
  }

  void _save() {
    try {
      HiveService.instance.cache.put(_key, state.map((a) => a.toMap()).toList());
    } catch (_) {}
  }

  String add({
    required String name,
    required AudienceKind kind,
    required FunnelStage stage,
    required int size,
    int percentMatch = 1,
    List<String> networks = const [],
    String? seedSource,
  }) {
    final id = _uuid.v4();
    state = [
      Audience(
        id: id,
        name: name,
        kind: kind,
        stage: stage,
        size: size,
        percentMatch: percentMatch,
        networks: networks,
        seedSource: seedSource,
      ),
      ...state,
    ];
    return id;
  }

  void toggleActive(String id) {
    state = [
      for (final a in state)
        if (a.id == id)
          (Audience(
            id: a.id, name: a.name, kind: a.kind, stage: a.stage, size: a.size,
            networks: a.networks, seedSource: a.seedSource, percentMatch: a.percentMatch,
            active: !a.active, createdAt: a.createdAt,
          ))
        else a,
    ];
  }

  void remove(String id) {
    state = state.where((a) => a.id != id).toList();
  }
}

final audiencesProvider = StateNotifierProvider<AudiencesNotifier, List<Audience>>(
    (_) => AudiencesNotifier());
