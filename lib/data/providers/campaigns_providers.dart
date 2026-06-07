import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/hive_service.dart';
import '../models/campaign.dart';

const _campaignsKey = 'campaigns.launched.v1';

/// A campaign actually launched through Mythrix (vs the seed/mock list).
class LaunchedCampaign {
  LaunchedCampaign({
    required this.id,
    required this.name,
    required this.networks,
    required this.objective,
    required this.dailyBudget,
    required this.bidStrategy,
    DateTime? launchedAt,
    this.status = CampaignStatus.active,
    this.spend = 0,
    this.impressions = 0,
    this.clicks = 0,
    this.conversions = 0,
    this.revenue = 0,
  }) : launchedAt = launchedAt ?? DateTime.now();

  final String id;
  final String name;
  final List<AdNetwork> networks;
  final CampaignObjective objective;
  final double dailyBudget;
  final String bidStrategy;
  final DateTime launchedAt;
  CampaignStatus status;
  double spend;
  int impressions;
  int clicks;
  int conversions;
  double revenue;

  // Derived metrics (mirror Campaign model).
  double get ctr => impressions == 0 ? 0 : clicks / impressions;
  double get cvr => clicks == 0 ? 0 : conversions / clicks;
  double get cpc => clicks == 0 ? 0 : spend / clicks;
  double get cpa => conversions == 0 ? 0 : spend / conversions;
  double get roas => spend == 0 ? 0 : revenue / spend;

  /// Used by the Ads Manager to render as a regular Campaign card.
  Campaign toCampaign() => Campaign(
        id: id,
        name: name,
        network: networks.isNotEmpty ? networks.first : AdNetwork.googleAds,
        objective: objective,
        status: status,
        startDate: launchedAt,
        dailyBudget: dailyBudget,
        spend: spend,
        impressions: impressions,
        clicks: clicks,
        conversions: conversions,
        revenue: revenue,
        audience: networks.map((n) => n.displayName).join(' + '),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'networks': networks.map((n) => n.name).toList(),
        'objective': objective.name,
        'dailyBudget': dailyBudget,
        'bidStrategy': bidStrategy,
        'launchedAt': launchedAt.toIso8601String(),
        'status': status.name,
        'spend': spend,
        'impressions': impressions,
        'clicks': clicks,
        'conversions': conversions,
        'revenue': revenue,
      };

  static LaunchedCampaign fromMap(Map<dynamic, dynamic> m) => LaunchedCampaign(
        id: m['id'] as String,
        name: m['name'] as String? ?? 'Untitled campaign',
        networks: ((m['networks'] as List?) ?? const [])
            .map((n) => AdNetwork.values.firstWhere(
                  (a) => a.name == n,
                  orElse: () => AdNetwork.googleAds,
                ))
            .toList(),
        objective: CampaignObjective.values.firstWhere(
          (o) => o.name == (m['objective'] as String?),
          orElse: () => CampaignObjective.sales,
        ),
        dailyBudget: (m['dailyBudget'] as num?)?.toDouble() ?? 0,
        bidStrategy: m['bidStrategy'] as String? ?? 'Target ROAS',
        launchedAt: DateTime.tryParse(m['launchedAt'] as String? ?? '') ?? DateTime.now(),
        status: CampaignStatus.values.firstWhere(
          (s) => s.name == (m['status'] as String?),
          orElse: () => CampaignStatus.active,
        ),
        spend: (m['spend'] as num?)?.toDouble() ?? 0,
        impressions: (m['impressions'] as num?)?.toInt() ?? 0,
        clicks: (m['clicks'] as num?)?.toInt() ?? 0,
        conversions: (m['conversions'] as num?)?.toInt() ?? 0,
        revenue: (m['revenue'] as num?)?.toDouble() ?? 0,
      );
}

class CampaignsNotifier extends StateNotifier<List<LaunchedCampaign>> {
  CampaignsNotifier() : super(_load()) {
    addListener((_) => _save());
  }

  final _uuid = const Uuid();

  static List<LaunchedCampaign> _load() {
    try {
      final raw = HiveService.instance.cache.get(_campaignsKey);
      if (raw is List) {
        return raw.map((e) => LaunchedCampaign.fromMap(e as Map)).toList()
          ..sort((a, b) => b.launchedAt.compareTo(a.launchedAt));
      }
    } catch (_) {}
    return [];
  }

  void _save() {
    try {
      HiveService.instance.cache.put(
        _campaignsKey,
        state.map((c) => c.toMap()).toList(),
      );
    } catch (_) {}
  }

  String launch({
    required String name,
    required List<AdNetwork> networks,
    required CampaignObjective objective,
    required double dailyBudget,
    required String bidStrategy,
  }) {
    final id = _uuid.v4();
    state = [
      LaunchedCampaign(
        id: id,
        name: name,
        networks: networks,
        objective: objective,
        dailyBudget: dailyBudget,
        bidStrategy: bidStrategy,
      ),
      ...state,
    ];
    return id;
  }

  void toggleStatus(String id) {
    state = [
      for (final c in state)
        if (c.id == id)
          (LaunchedCampaign(
            id: c.id,
            name: c.name,
            networks: c.networks,
            objective: c.objective,
            dailyBudget: c.dailyBudget,
            bidStrategy: c.bidStrategy,
            launchedAt: c.launchedAt,
            status: c.status == CampaignStatus.active
                ? CampaignStatus.paused
                : CampaignStatus.active,
            spend: c.spend,
            impressions: c.impressions,
            clicks: c.clicks,
            conversions: c.conversions,
            revenue: c.revenue,
          ))
        else
          c,
    ];
  }

  void remove(String id) {
    state = state.where((c) => c.id != id).toList();
  }

  void clear() {
    state = [];
  }
}

final campaignsStoreProvider =
    StateNotifierProvider<CampaignsNotifier, List<LaunchedCampaign>>(
        (_) => CampaignsNotifier());
