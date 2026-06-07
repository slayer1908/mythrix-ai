import 'dart:math' as math;

import '../constants/app_constants.dart';
import '../../data/models/campaign.dart';
import '../../data/models/content_draft.dart';
import '../../data/models/insight.dart';
import '../../data/models/scheduled_post.dart';

/// Deterministic mock data so the UI shows realistic numbers in V1.
class MockData {
  MockData._();
  static final _rng = math.Random(42);

  static List<Campaign> campaigns() {
    final now = DateTime.now();
    return [
      Campaign(
        id: 'cmp_001',
        name: 'Summer Drop · Performance Max',
        network: AdNetwork.googleAds,
        objective: CampaignObjective.sales,
        status: CampaignStatus.active,
        startDate: now.subtract(const Duration(days: 14)),
        dailyBudget: 250,
        spend: 3120.45,
        impressions: 482300,
        clicks: 18432,
        conversions: 412,
        revenue: 28940.10,
        audience: 'Active shoppers 25–44, US/CA',
      ),
      Campaign(
        id: 'cmp_002',
        name: 'Hero Reel · IG + FB',
        network: AdNetwork.metaAds,
        objective: CampaignObjective.engagement,
        status: CampaignStatus.active,
        startDate: now.subtract(const Duration(days: 9)),
        dailyBudget: 180,
        spend: 1583.20,
        impressions: 312100,
        clicks: 9810,
        conversions: 154,
        revenue: 9870.00,
        audience: 'Lookalike 1% of past purchasers',
      ),
      Campaign(
        id: 'cmp_003',
        name: 'B2B SaaS — Decision Makers',
        network: AdNetwork.linkedinAds,
        objective: CampaignObjective.leads,
        status: CampaignStatus.active,
        startDate: now.subtract(const Duration(days: 30)),
        dailyBudget: 300,
        spend: 8420.00,
        impressions: 184320,
        clicks: 3120,
        conversions: 87,
        revenue: 41200.00,
        audience: 'Heads of Marketing, 200+ employees',
      ),
      Campaign(
        id: 'cmp_004',
        name: 'TikTok Creator Sparks',
        network: AdNetwork.tiktokAds,
        objective: CampaignObjective.awareness,
        status: CampaignStatus.paused,
        startDate: now.subtract(const Duration(days: 21)),
        dailyBudget: 120,
        spend: 1840.30,
        impressions: 1280300,
        clicks: 22130,
        conversions: 198,
        revenue: 8120.00,
        audience: 'Gen Z, urban metros',
      ),
      Campaign(
        id: 'cmp_005',
        name: 'Retargeting — Cart Abandoners',
        network: AdNetwork.metaAds,
        objective: CampaignObjective.conversions,
        status: CampaignStatus.active,
        startDate: now.subtract(const Duration(days: 45)),
        dailyBudget: 90,
        spend: 3210.00,
        impressions: 98200,
        clicks: 8120,
        conversions: 982,
        revenue: 52400.00,
        audience: 'Cart abandoners, last 14 days',
      ),
      Campaign(
        id: 'cmp_006',
        name: 'Search · Branded Terms',
        network: AdNetwork.googleAds,
        objective: CampaignObjective.traffic,
        status: CampaignStatus.active,
        startDate: now.subtract(const Duration(days: 90)),
        dailyBudget: 60,
        spend: 4920.00,
        impressions: 84200,
        clicks: 12030,
        conversions: 1280,
        revenue: 78400.00,
        audience: 'Brand keywords, exact match',
      ),
    ];
  }

  static List<ScheduledPost> upcomingPosts() {
    final now = DateTime.now();
    return [
      ScheduledPost(
        id: 'p1',
        title: 'Behind-the-scenes — new collection drop',
        body: 'A peek behind the curtain of our most anticipated collection yet. Drop your guesses 👇',
        channels: const [SocialChannel.instagram, SocialChannel.tiktok],
        scheduledFor: now.add(const Duration(hours: 2)),
        hashtags: const ['#newdrop', '#bts', '#sneakpeek'],
        aiGenerated: true,
      ),
      ScheduledPost(
        id: 'p2',
        title: 'Why the smartest CMOs are betting on autonomous marketing',
        body: 'A 7-minute read on how AI orchestration is becoming the new growth lever.',
        channels: const [SocialChannel.linkedin, SocialChannel.twitter],
        scheduledFor: now.add(const Duration(hours: 6)),
        hashtags: const ['#cmo', '#aimarketing', '#growth'],
      ),
      ScheduledPost(
        id: 'p3',
        title: 'Friday demo — MYTHRIX Auto-Pilot live',
        body: 'Join us live as MYTHRIX launches, scales and optimizes a full Google + Meta campaign in 90 seconds.',
        channels: const [SocialChannel.youtube, SocialChannel.linkedin, SocialChannel.twitter],
        scheduledFor: now.add(const Duration(days: 1, hours: 3)),
        aiGenerated: true,
      ),
      ScheduledPost(
        id: 'p4',
        title: 'Customer love — Brewline 4.2× ROAS',
        body: 'How Brewline used MYTHRIX to scale spend 6× while improving ROAS to 4.2×.',
        channels: const [SocialChannel.linkedin, SocialChannel.facebook],
        scheduledFor: now.add(const Duration(days: 2)),
      ),
    ];
  }

  static List<Insight> insights() {
    final now = DateTime.now();
    return [
      Insight(
        id: 'i1',
        title: 'Shift \$420/day from "Search · Brand" → "Performance Max"',
        summary: 'Performance Max is converting 31% cheaper this week with headroom on impression share.',
        severity: InsightSeverity.opportunity,
        createdAt: now.subtract(const Duration(minutes: 18)),
        recommendation: 'MYTHRIX can rebalance budgets automatically. Approve to apply.',
        estimatedImpact: '+\$3,840 weekly revenue',
        relatedEntity: 'Google Ads',
        action: 'Apply rebalance',
      ),
      Insight(
        id: 'i2',
        title: 'Creative fatigue detected on "Hero Reel"',
        summary: 'CTR dropped 28% over the last 48h. Consider rotating in 3 new variants.',
        severity: InsightSeverity.warning,
        createdAt: now.subtract(const Duration(hours: 1)),
        recommendation: 'Generate 3 on-brand video variations from the source asset.',
        estimatedImpact: 'Recover ~22% engagement',
        relatedEntity: 'Meta Ads · Hero Reel',
        action: 'Generate variants',
      ),
      Insight(
        id: 'i3',
        title: '12 negative keywords automatically applied',
        summary: 'MYTHRIX excluded 12 wasteful terms (avg CPC \$2.81, 0 conversions over 30 days).',
        severity: InsightSeverity.info,
        createdAt: now.subtract(const Duration(hours: 4)),
        recommendation: 'Review the list. Nothing changes unless you reverse.',
        estimatedImpact: '-\$640 weekly waste',
        relatedEntity: 'Google Ads',
        action: 'Review list',
      ),
      Insight(
        id: 'i4',
        title: 'Audience overlap > 38% between two ad sets',
        summary: '"Lookalike 1%" and "Retargeting 30d" are competing for the same users.',
        severity: InsightSeverity.warning,
        createdAt: now.subtract(const Duration(hours: 7)),
        recommendation: 'Consolidate or exclude overlapping audiences.',
        estimatedImpact: 'Lower CPM ~14%',
        relatedEntity: 'Meta Ads',
        action: 'Resolve overlap',
      ),
    ];
  }

  static List<ContentDraft> recentDrafts() {
    final now = DateTime.now();
    return [
      ContentDraft(
        id: 'd1',
        title: 'IG carousel — 5 myths about AI marketing',
        body: 'Myth 1: AI replaces creativity. Reality: it amplifies it...',
        type: ContentType.socialPost,
        tone: ContentTone.witty,
        createdAt: now.subtract(const Duration(minutes: 22)),
        starred: true,
      ),
      ContentDraft(
        id: 'd2',
        title: 'Google Ads — Performance Max headlines (15 variants)',
        body: 'Headlines tuned for purchase intent across product categories.',
        type: ContentType.adCopy,
        tone: ContentTone.urgent,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 5)),
      ),
      ContentDraft(
        id: 'd3',
        title: 'Welcome email — premium tier upgrade',
        body: 'Hi {{first_name}}, welcome to the inner circle...',
        type: ContentType.email,
        tone: ContentTone.luxury,
        createdAt: now.subtract(const Duration(hours: 5)),
        starred: true,
      ),
      ContentDraft(
        id: 'd4',
        title: 'Blog post — Q3 attribution playbook',
        body: 'A practitioner\'s guide to multi-touch attribution in 2026.',
        type: ContentType.blogPost,
        tone: ContentTone.authoritative,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
    ];
  }

  /// Returns 30 days of synthetic timeseries for trend charts.
  static List<double> trend({double base = 100, double drift = 1.6, double noise = 14}) {
    return List.generate(30, (i) {
      final t = i.toDouble();
      return base + drift * t + (_rng.nextDouble() - 0.5) * noise;
    });
  }
}
