import '../../../data/models/campaign.dart';
import '../../constants/app_constants.dart';

/// Common interface every ad-platform integration implements.
///
/// Implementations:
///   * [GoogleAdsService]   — google_ads_service.dart
///   * [MetaAdsService]     — meta_ads_service.dart
///   * [TikTokAdsService]   — tiktok_ads_service.dart
///   * [LinkedInAdsService] — linkedin_ads_service.dart
abstract class CampaignService {
  /// The platform this service talks to.
  AdNetwork get network;

  /// Whether the user has connected their account.
  Future<bool> isConnected();

  /// Kick off OAuth (returns the URL to open in a browser / webview).
  Future<String> beginOAuth();

  /// Complete OAuth from the redirect callback.
  Future<void> completeOAuth(String code, {String? state});

  /// Disconnect — revokes tokens and forgets the account.
  Future<void> disconnect();

  /// Fetch campaigns for the connected account.
  Future<List<Campaign>> listCampaigns();

  /// Create a campaign on the platform.
  Future<Campaign> createCampaign(CampaignDraft draft);

  /// Pause / resume / archive a campaign.
  Future<void> updateStatus(String id, CampaignStatus next);

  /// Live performance metrics for the last `lookbackDays`.
  Future<CampaignMetrics> metrics(String id, {int lookbackDays = 7});
}

class CampaignDraft {
  const CampaignDraft({
    required this.name,
    required this.objective,
    required this.dailyBudget,
    required this.startDate,
    this.endDate,
    this.audience = '',
    this.bidStrategy = 'Target ROAS',
    this.negativeKeywords = const [],
  });

  final String name;
  final CampaignObjective objective;
  final double dailyBudget;
  final DateTime startDate;
  final DateTime? endDate;
  final String audience;
  final String bidStrategy;
  final List<String> negativeKeywords;
}

class CampaignMetrics {
  const CampaignMetrics({
    required this.impressions,
    required this.clicks,
    required this.spend,
    required this.conversions,
    required this.revenue,
  });
  final int impressions;
  final int clicks;
  final double spend;
  final int conversions;
  final double revenue;
}
