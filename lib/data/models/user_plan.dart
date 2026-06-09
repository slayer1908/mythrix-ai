/// The three plan tiers Mythrix sells. Mirrors what's on the Pricing page.
enum PlanTier { starter, pro, agency }

extension PlanTierX on PlanTier {
  String get label {
    switch (this) {
      case PlanTier.starter: return 'Starter';
      case PlanTier.pro: return 'Pro';
      case PlanTier.agency: return 'Agency';
    }
  }

  String get tagline {
    switch (this) {
      case PlanTier.starter: return 'Free forever';
      case PlanTier.pro: return '\$29/mo · 14-day trial';
      case PlanTier.agency: return '\$99/mo · unlimited clients';
    }
  }

  /// Display color hint. Used by the Billing screen and "Pro" badges.
  int get colorValue {
    switch (this) {
      case PlanTier.starter: return 0xFF9CA3AF;
      case PlanTier.pro: return 0xFF7C5CFF;
      case PlanTier.agency: return 0xFFEC4899;
    }
  }
}

/// Hard limits enforced per-tier. Tells the UI when to show "Upgrade" prompts.
class PlanLimits {
  const PlanLimits({
    required this.maxBrands,
    required this.maxImagesPerMonth,
    required this.maxScheduledPostsPerMonth,
    required this.maxCampaigns,
    required this.realPublishingEnabled,
    required this.realAdOAuthEnabled,
    required this.premiumAIAllowed,
    required this.teamSeats,
  });

  final int maxBrands;
  final int maxImagesPerMonth;
  final int maxScheduledPostsPerMonth;
  final int maxCampaigns;
  final bool realPublishingEnabled;
  final bool realAdOAuthEnabled;
  final bool premiumAIAllowed;
  final int teamSeats;

  static const PlanLimits starter = PlanLimits(
    maxBrands: 1,
    maxImagesPerMonth: 30,
    maxScheduledPostsPerMonth: 50,
    maxCampaigns: 3,
    realPublishingEnabled: false,
    realAdOAuthEnabled: false,
    premiumAIAllowed: false,
    teamSeats: 1,
  );

  static const PlanLimits pro = PlanLimits(
    maxBrands: 5,
    maxImagesPerMonth: 9999,
    maxScheduledPostsPerMonth: 9999,
    maxCampaigns: 9999,
    realPublishingEnabled: true,
    realAdOAuthEnabled: true,
    premiumAIAllowed: true,
    teamSeats: 1,
  );

  static const PlanLimits agency = PlanLimits(
    maxBrands: 9999,
    maxImagesPerMonth: 9999,
    maxScheduledPostsPerMonth: 9999,
    maxCampaigns: 9999,
    realPublishingEnabled: true,
    realAdOAuthEnabled: true,
    premiumAIAllowed: true,
    teamSeats: 5,
  );

  static PlanLimits forTier(PlanTier tier) {
    switch (tier) {
      case PlanTier.starter: return starter;
      case PlanTier.pro: return pro;
      case PlanTier.agency: return agency;
    }
  }
}

/// State stored in Firestore at users/{uid}/meta/billing.
class UserPlan {
  UserPlan({
    required this.tier,
    this.trialEndsAt,
    this.subscribedAt,
    this.razorpayCustomerId,
    this.cancelAtPeriodEnd = false,
  });

  final PlanTier tier;
  final DateTime? trialEndsAt;
  final DateTime? subscribedAt;
  final String? razorpayCustomerId;
  final bool cancelAtPeriodEnd;

  PlanLimits get limits => PlanLimits.forTier(tier);

  bool get isOnTrial =>
      tier != PlanTier.starter &&
      trialEndsAt != null &&
      trialEndsAt!.isAfter(DateTime.now());

  int get trialDaysLeft {
    if (!isOnTrial) return 0;
    return trialEndsAt!.difference(DateTime.now()).inDays;
  }

  bool get isPaying => tier != PlanTier.starter && !isOnTrial;

  Map<String, dynamic> toMap() => {
        'tier': tier.name,
        'trialEndsAt': trialEndsAt?.toIso8601String(),
        'subscribedAt': subscribedAt?.toIso8601String(),
        'razorpayCustomerId': razorpayCustomerId,
        'cancelAtPeriodEnd': cancelAtPeriodEnd,
      };

  static UserPlan fromMap(Map<dynamic, dynamic> m) => UserPlan(
        tier: PlanTier.values.firstWhere(
          (t) => t.name == m['tier'],
          orElse: () => PlanTier.starter,
        ),
        trialEndsAt: m['trialEndsAt'] != null
            ? DateTime.tryParse(m['trialEndsAt'] as String)
            : null,
        subscribedAt: m['subscribedAt'] != null
            ? DateTime.tryParse(m['subscribedAt'] as String)
            : null,
        razorpayCustomerId: m['razorpayCustomerId'] as String?,
        cancelAtPeriodEnd: m['cancelAtPeriodEnd'] as bool? ?? false,
      );

  /// The default plan a brand-new user gets on signup.
  static UserPlan defaultStarter() => UserPlan(tier: PlanTier.starter);
}
