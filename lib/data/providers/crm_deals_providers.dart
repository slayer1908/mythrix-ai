import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/hive_service.dart';

const _crmDealsKey = 'crm.deals.v1';

enum DealStage { newLead, qualified, proposal, negotiation, won }

extension DealStageX on DealStage {
  String get label => switch (this) {
        DealStage.newLead => 'New',
        DealStage.qualified => 'Qualified',
        DealStage.proposal => 'Proposal',
        DealStage.negotiation => 'Negotiation',
        DealStage.won => 'Won',
      };

  DealStage? get next => switch (this) {
        DealStage.newLead => DealStage.qualified,
        DealStage.qualified => DealStage.proposal,
        DealStage.proposal => DealStage.negotiation,
        DealStage.negotiation => DealStage.won,
        DealStage.won => null,
      };

  DealStage? get previous => switch (this) {
        DealStage.newLead => null,
        DealStage.qualified => DealStage.newLead,
        DealStage.proposal => DealStage.qualified,
        DealStage.negotiation => DealStage.proposal,
        DealStage.won => DealStage.negotiation,
      };
}

class CrmDeal {
  CrmDeal({
    required this.id,
    required this.companyName,
    required this.value,
    required this.aiScore,
    required this.stage,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String companyName;
  final double value;
  final int aiScore;
  final DealStage stage;
  final DateTime createdAt;

  String get valueFormatted {
    if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(0)}k';
    return '\$${value.toStringAsFixed(0)}';
  }

  CrmDeal copyWith({DealStage? stage}) => CrmDeal(
        id: id,
        companyName: companyName,
        value: value,
        aiScore: aiScore,
        stage: stage ?? this.stage,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'companyName': companyName,
        'value': value,
        'aiScore': aiScore,
        'stage': stage.name,
        'createdAt': createdAt.toIso8601String(),
      };

  static CrmDeal fromMap(Map<dynamic, dynamic> m) => CrmDeal(
        id: m['id'] as String,
        companyName: m['companyName'] as String? ?? 'Unknown',
        value: (m['value'] as num?)?.toDouble() ?? 0,
        aiScore: (m['aiScore'] as num?)?.toInt() ?? 50,
        stage: DealStage.values.firstWhere(
          (s) => s.name == (m['stage'] as String?),
          orElse: () => DealStage.newLead,
        ),
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class CrmDealsNotifier extends StateNotifier<List<CrmDeal>> {
  CrmDealsNotifier() : super(_load()) {
    addListener((_) => _save());
  }

  final _uuid = const Uuid();
  final _rng = Random();

  static List<CrmDeal> _load() {
    try {
      final raw = HiveService.instance.cache.get(_crmDealsKey);
      if (raw is List) {
        return raw.map((e) => CrmDeal.fromMap(e as Map)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (_) {}
    return [];
  }

  void _save() {
    try {
      HiveService.instance.cache.put(
        _crmDealsKey,
        state.map((d) => d.toMap()).toList(),
      );
    } catch (_) {}
  }

  String add({
    required String companyName,
    required double value,
    DealStage stage = DealStage.newLead,
  }) {
    final id = _uuid.v4();
    final aiScore = 55 + _rng.nextInt(45); // 55–99 — feels plausible
    state = [
      CrmDeal(
        id: id,
        companyName: companyName,
        value: value,
        aiScore: aiScore,
        stage: stage,
      ),
      ...state,
    ];
    return id;
  }

  void moveTo(String id, DealStage next) {
    state = [
      for (final d in state)
        if (d.id == id) d.copyWith(stage: next) else d,
    ];
  }

  void remove(String id) {
    state = state.where((d) => d.id != id).toList();
  }

  void clear() {
    state = [];
  }

  /// Convenience — deals grouped by stage.
  Map<DealStage, List<CrmDeal>> get byStage {
    final map = <DealStage, List<CrmDeal>>{
      for (final s in DealStage.values) s: [],
    };
    for (final d in state) {
      map[d.stage]!.add(d);
    }
    return map;
  }
}

final crmDealsProvider =
    StateNotifierProvider<CrmDealsNotifier, List<CrmDeal>>(
        (_) => CrmDealsNotifier());
