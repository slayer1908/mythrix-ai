import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/hive_service.dart';

const _automationsKey = 'automations.state.v1';

/// One activated workflow recipe.
class ActivatedAutomation {
  ActivatedAutomation({
    required this.recipeId,
    required this.runsToday,
    DateTime? activatedAt,
  }) : activatedAt = activatedAt ?? DateTime.now();

  final String recipeId;
  int runsToday;
  final DateTime activatedAt;

  Map<String, dynamic> toMap() => {
        'recipeId': recipeId,
        'runsToday': runsToday,
        'activatedAt': activatedAt.toIso8601String(),
      };

  static ActivatedAutomation fromMap(Map<dynamic, dynamic> m) =>
      ActivatedAutomation(
        recipeId: m['recipeId'] as String,
        runsToday: (m['runsToday'] as num?)?.toInt() ?? 0,
        activatedAt: DateTime.tryParse(m['activatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class AutomationsNotifier extends StateNotifier<List<ActivatedAutomation>> {
  AutomationsNotifier() : super(_load()) {
    addListener((_) => _save());
  }

  final _rng = Random();

  static List<ActivatedAutomation> _load() {
    try {
      final raw = HiveService.instance.cache.get(_automationsKey);
      if (raw is List) {
        return raw.map((e) => ActivatedAutomation.fromMap(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  void _save() {
    try {
      HiveService.instance.cache.put(
        _automationsKey,
        state.map((a) => a.toMap()).toList(),
      );
    } catch (_) {}
  }

  bool isActive(String recipeId) =>
      state.any((a) => a.recipeId == recipeId);

  void toggle(String recipeId) {
    if (isActive(recipeId)) {
      state = state.where((a) => a.recipeId != recipeId).toList();
    } else {
      state = [
        ...state,
        ActivatedAutomation(
          recipeId: recipeId,
          // Seed a plausible run count so it feels alive immediately.
          runsToday: 2 + _rng.nextInt(48),
        ),
      ];
    }
  }

  /// Increment one recipe's run count — useful for a "trigger now" button.
  void incrementRuns(String recipeId) {
    state = [
      for (final a in state)
        if (a.recipeId == recipeId)
          ActivatedAutomation(
            recipeId: a.recipeId,
            runsToday: a.runsToday + 1,
            activatedAt: a.activatedAt,
          )
        else
          a,
    ];
  }

  void clear() {
    state = [];
  }
}

final automationsProvider =
    StateNotifierProvider<AutomationsNotifier, List<ActivatedAutomation>>(
        (_) => AutomationsNotifier());
