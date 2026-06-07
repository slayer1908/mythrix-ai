enum ConversionPlatform { ga4, metaCapi, googleAdsClickId, tiktokEvents, linkedinInsight, pinterestConversions, redditPixel, customServer }

extension ConversionPlatformX on ConversionPlatform {
  String get label {
    switch (this) {
      case ConversionPlatform.ga4: return 'GA4';
      case ConversionPlatform.metaCapi: return 'Meta CAPI';
      case ConversionPlatform.googleAdsClickId: return 'Google Ads (GCLID)';
      case ConversionPlatform.tiktokEvents: return 'TikTok Events API';
      case ConversionPlatform.linkedinInsight: return 'LinkedIn Insight Tag';
      case ConversionPlatform.pinterestConversions: return 'Pinterest Conversions API';
      case ConversionPlatform.redditPixel: return 'Reddit Pixel';
      case ConversionPlatform.customServer: return 'Custom server-side';
    }
  }
}

enum AttributionWindow { oneDayClick, sevenDayClick, oneDayView, sevenDayClickOneDayView, twentyEightDayClick, dataDriven }

extension AttributionWindowX on AttributionWindow {
  String get label {
    switch (this) {
      case AttributionWindow.oneDayClick: return '1-day click';
      case AttributionWindow.sevenDayClick: return '7-day click';
      case AttributionWindow.oneDayView: return '1-day view';
      case AttributionWindow.sevenDayClickOneDayView: return '7-day click + 1-day view';
      case AttributionWindow.twentyEightDayClick: return '28-day click';
      case AttributionWindow.dataDriven: return 'Data-driven (recommended)';
    }
  }
}

class ConversionEvent {
  ConversionEvent({
    required this.id,
    required this.name,
    required this.platform,
    required this.value,
    required this.window,
    this.currency = 'USD',
    this.enabled = true,
    this.serverSide = false,
    DateTime? createdAt,
    this.firedCount = 0,
    this.lastFiredAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  String name;
  ConversionPlatform platform;
  double value;
  AttributionWindow window;
  String currency;
  bool enabled;
  bool serverSide;
  final DateTime createdAt;
  int firedCount;
  DateTime? lastFiredAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'platform': platform.name,
        'value': value,
        'window': window.name,
        'currency': currency,
        'enabled': enabled,
        'serverSide': serverSide,
        'createdAt': createdAt.toIso8601String(),
        'firedCount': firedCount,
        'lastFiredAt': lastFiredAt?.toIso8601String(),
      };

  static ConversionEvent fromMap(Map<dynamic, dynamic> m) => ConversionEvent(
        id: m['id'] as String,
        name: m['name'] as String? ?? 'Conversion',
        platform: ConversionPlatform.values.firstWhere(
          (p) => p.name == m['platform'],
          orElse: () => ConversionPlatform.ga4,
        ),
        value: (m['value'] as num?)?.toDouble() ?? 0,
        window: AttributionWindow.values.firstWhere(
          (w) => w.name == m['window'],
          orElse: () => AttributionWindow.sevenDayClickOneDayView,
        ),
        currency: m['currency'] as String? ?? 'USD',
        enabled: m['enabled'] as bool? ?? true,
        serverSide: m['serverSide'] as bool? ?? false,
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
        firedCount: (m['firedCount'] as num?)?.toInt() ?? 0,
        lastFiredAt: m['lastFiredAt'] != null
            ? DateTime.tryParse(m['lastFiredAt'] as String)
            : null,
      );
}

/// Standard e-commerce + lead-gen conversion event library.
const kStandardEvents = <Map<String, dynamic>>[
  {'name': 'Purchase', 'value': 0.0, 'icon': '🛒'},
  {'name': 'Add to cart', 'value': 0.0, 'icon': '➕'},
  {'name': 'Initiate checkout', 'value': 0.0, 'icon': '💳'},
  {'name': 'Add payment info', 'value': 0.0, 'icon': '💰'},
  {'name': 'Lead form submit', 'value': 25.0, 'icon': '📝'},
  {'name': 'Schedule demo', 'value': 100.0, 'icon': '📅'},
  {'name': 'Sign up (trial)', 'value': 15.0, 'icon': '🆕'},
  {'name': 'Subscribe (paid)', 'value': 49.0, 'icon': '⭐'},
  {'name': 'Contact form', 'value': 10.0, 'icon': '📨'},
  {'name': 'Call clicked', 'value': 20.0, 'icon': '📞'},
  {'name': 'Newsletter signup', 'value': 2.0, 'icon': '📰'},
  {'name': 'Search', 'value': 0.0, 'icon': '🔍'},
];
