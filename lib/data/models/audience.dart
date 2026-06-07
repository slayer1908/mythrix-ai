enum AudienceKind {
  custom,        // user-uploaded list (CRM, email)
  lookalike,     // % similar to seed
  interest,      // platform's interest graph
  retargeting,   // site visitors, video viewers, engagers
  abm,           // account-based — uploaded company list
  weather,       // weather-triggered conditions
  contextual,    // page-content based
}

extension AudienceKindX on AudienceKind {
  String get label {
    switch (this) {
      case AudienceKind.custom: return 'Custom list';
      case AudienceKind.lookalike: return 'Lookalike';
      case AudienceKind.interest: return 'Interest';
      case AudienceKind.retargeting: return 'Retargeting';
      case AudienceKind.abm: return 'Account-based (ABM)';
      case AudienceKind.weather: return 'Weather-triggered';
      case AudienceKind.contextual: return 'Contextual';
    }
  }
}

enum FunnelStage { cold, warm, hot, retention }

extension FunnelStageX on FunnelStage {
  String get label {
    switch (this) {
      case FunnelStage.cold: return 'Cold — prospecting';
      case FunnelStage.warm: return 'Warm — engaged';
      case FunnelStage.hot: return 'Hot — high intent';
      case FunnelStage.retention: return 'Retention — buyers';
    }
  }
}

class Audience {
  Audience({
    required this.id,
    required this.name,
    required this.kind,
    required this.stage,
    required this.size,
    this.networks = const [],
    this.seedSource,
    this.percentMatch = 1,
    this.active = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  String name;
  AudienceKind kind;
  FunnelStage stage;
  int size;
  List<String> networks;
  String? seedSource;
  int percentMatch;
  bool active;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'kind': kind.name,
        'stage': stage.name,
        'size': size,
        'networks': networks,
        'seedSource': seedSource,
        'percentMatch': percentMatch,
        'active': active,
        'createdAt': createdAt.toIso8601String(),
      };

  static Audience fromMap(Map<dynamic, dynamic> m) => Audience(
        id: m['id'] as String,
        name: m['name'] as String? ?? 'Audience',
        kind: AudienceKind.values.firstWhere((k) => k.name == m['kind'], orElse: () => AudienceKind.custom),
        stage: FunnelStage.values.firstWhere((s) => s.name == m['stage'], orElse: () => FunnelStage.cold),
        size: (m['size'] as num?)?.toInt() ?? 0,
        networks: (m['networks'] as List?)?.cast<String>() ?? const [],
        seedSource: m['seedSource'] as String?,
        percentMatch: (m['percentMatch'] as num?)?.toInt() ?? 1,
        active: m['active'] as bool? ?? true,
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Madgicx-inspired AI Audience Launcher — pre-built clusters across the funnel.
const kAudienceTemplates = <Map<String, dynamic>>[
  // COLD
  {'name': 'Lookalike 1% — Top Purchasers', 'kind': AudienceKind.lookalike, 'stage': FunnelStage.cold, 'size': 1800000, 'percentMatch': 1},
  {'name': 'Lookalike 5% — Email Subscribers', 'kind': AudienceKind.lookalike, 'stage': FunnelStage.cold, 'size': 9200000, 'percentMatch': 5},
  {'name': 'Interest — Competitors + Adjacent Brands', 'kind': AudienceKind.interest, 'stage': FunnelStage.cold, 'size': 24000000, 'percentMatch': 1},
  {'name': 'Contextual — Industry News Sites', 'kind': AudienceKind.contextual, 'stage': FunnelStage.cold, 'size': 6800000, 'percentMatch': 1},
  // WARM
  {'name': 'Video Viewers 75%+ — Last 30d', 'kind': AudienceKind.retargeting, 'stage': FunnelStage.warm, 'size': 84000, 'percentMatch': 1},
  {'name': 'Engaged Page Visitors — 30d', 'kind': AudienceKind.retargeting, 'stage': FunnelStage.warm, 'size': 142000, 'percentMatch': 1},
  {'name': 'Engaged IG / FB Profiles — 60d', 'kind': AudienceKind.retargeting, 'stage': FunnelStage.warm, 'size': 67000, 'percentMatch': 1},
  // HOT
  {'name': 'Cart Abandoners — 14d', 'kind': AudienceKind.retargeting, 'stage': FunnelStage.hot, 'size': 12400, 'percentMatch': 1},
  {'name': 'Checkout Started — 7d', 'kind': AudienceKind.retargeting, 'stage': FunnelStage.hot, 'size': 6800, 'percentMatch': 1},
  {'name': 'Lead Form Started, Not Submitted', 'kind': AudienceKind.retargeting, 'stage': FunnelStage.hot, 'size': 3200, 'percentMatch': 1},
  // RETENTION
  {'name': 'Existing Customers — Last Purchase 90d', 'kind': AudienceKind.custom, 'stage': FunnelStage.retention, 'size': 18400, 'percentMatch': 1},
  {'name': 'High-LTV Cohort (top 10%)', 'kind': AudienceKind.custom, 'stage': FunnelStage.retention, 'size': 1840, 'percentMatch': 1},
  {'name': 'Win-back — No purchase 180d+', 'kind': AudienceKind.custom, 'stage': FunnelStage.retention, 'size': 42000, 'percentMatch': 1},
];
