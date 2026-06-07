import '../../core/constants/app_constants.dart';

enum CampaignStatus { draft, scheduled, active, paused, completed, error }

enum CampaignObjective {
  awareness,
  traffic,
  engagement,
  leads,
  appPromotion,
  sales,
  conversions,
  storeVisits,
}

class Campaign {
  const Campaign({
    required this.id,
    required this.name,
    required this.network,
    required this.objective,
    required this.status,
    required this.startDate,
    this.endDate,
    this.dailyBudget = 0,
    this.totalBudget = 0,
    this.spend = 0,
    this.impressions = 0,
    this.clicks = 0,
    this.conversions = 0,
    this.revenue = 0,
    this.audience = '',
  });

  final String id;
  final String name;
  final AdNetwork network;
  final CampaignObjective objective;
  final CampaignStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final double dailyBudget;
  final double totalBudget;
  final double spend;
  final int impressions;
  final int clicks;
  final int conversions;
  final double revenue;
  final String audience;

  double get ctr => impressions == 0 ? 0 : clicks / impressions;
  double get cvr => clicks == 0 ? 0 : conversions / clicks;
  double get cpc => clicks == 0 ? 0 : spend / clicks;
  double get cpa => conversions == 0 ? 0 : spend / conversions;
  double get roas => spend == 0 ? 0 : revenue / spend;
}

extension CampaignObjectiveX on CampaignObjective {
  String get displayName {
    switch (this) {
      case CampaignObjective.awareness:
        return 'Brand awareness';
      case CampaignObjective.traffic:
        return 'Traffic';
      case CampaignObjective.engagement:
        return 'Engagement';
      case CampaignObjective.leads:
        return 'Lead generation';
      case CampaignObjective.appPromotion:
        return 'App installs';
      case CampaignObjective.sales:
        return 'Sales';
      case CampaignObjective.conversions:
        return 'Conversions';
      case CampaignObjective.storeVisits:
        return 'Store visits';
    }
  }
}
