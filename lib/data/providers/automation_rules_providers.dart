import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/hive_service.dart';
import '../models/automation_rule.dart';

const _rulesKey = 'automation.rules.v1';

class AutomationRulesNotifier extends StateNotifier<List<AutomationRule>> {
  AutomationRulesNotifier() : super(_load()) {
    addListener((_) => _save());
  }

  final _uuid = const Uuid();

  static List<AutomationRule> _load() {
    try {
      final raw = HiveService.instance.cache.get(_rulesKey);
      if (raw is List) {
        return raw.map((e) => AutomationRule.fromMap(e as Map)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (_) {}
    return [];
  }

  void _save() {
    try {
      HiveService.instance.cache.put(
        _rulesKey,
        state.map((r) => r.toMap()).toList(),
      );
    } catch (_) {}
  }

  String add({
    required String name,
    required RuleTrigger trigger,
    required double triggerValue,
    required RuleAction action,
    double? actionValue,
    RuleScope scope = RuleScope.allCampaigns,
    String? scopeTarget,
  }) {
    final id = _uuid.v4();
    state = [
      AutomationRule(
        id: id,
        name: name,
        trigger: trigger,
        triggerValue: triggerValue,
        action: action,
        actionValue: actionValue,
        scope: scope,
        scopeTarget: scopeTarget,
      ),
      ...state,
    ];
    return id;
  }

  void toggleEnabled(String id) {
    state = [
      for (final r in state)
        if (r.id == id)
          (AutomationRule(
            id: r.id,
            name: r.name,
            trigger: r.trigger,
            triggerValue: r.triggerValue,
            action: r.action,
            actionValue: r.actionValue,
            scope: r.scope,
            scopeTarget: r.scopeTarget,
            enabled: !r.enabled,
            createdAt: r.createdAt,
            timesFired: r.timesFired,
            lastFiredAt: r.lastFiredAt,
          ))
        else
          r,
    ];
  }

  void recordFire(String id) {
    state = [
      for (final r in state)
        if (r.id == id)
          (AutomationRule(
            id: r.id,
            name: r.name,
            trigger: r.trigger,
            triggerValue: r.triggerValue,
            action: r.action,
            actionValue: r.actionValue,
            scope: r.scope,
            scopeTarget: r.scopeTarget,
            enabled: r.enabled,
            createdAt: r.createdAt,
            timesFired: r.timesFired + 1,
            lastFiredAt: DateTime.now(),
          ))
        else
          r,
    ];
  }

  void remove(String id) {
    state = state.where((r) => r.id != id).toList();
  }

  void clear() {
    state = [];
  }
}

final automationRulesProvider =
    StateNotifierProvider<AutomationRulesNotifier, List<AutomationRule>>(
        (_) => AutomationRulesNotifier());

final activeRulesCountProvider = Provider<int>(
  (ref) => ref.watch(automationRulesProvider).where((r) => r.enabled).length,
);
