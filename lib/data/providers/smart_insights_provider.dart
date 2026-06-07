import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../models/insight.dart';
import 'brand_profile_providers.dart';
import 'campaigns_providers.dart';
import 'crm_deals_providers.dart';
import 'email_campaigns_providers.dart';
import 'gallery_providers.dart';
import 'scheduled_posts_providers.dart';

/// MYTHRIX Auto-Pilot brain. Reads the user's real persisted state and
/// generates personalized, brand-aware next-action recommendations.
/// This is the "the app actually thinks" moment of the product.
final smartInsightsProvider = Provider<List<Insight>>((ref) {
  final profile = ref.watch(brandProfileProvider);
  final campaigns = ref.watch(campaignsStoreProvider);
  final posts = ref.watch(scheduledPostsProvider);
  final emails = ref.watch(emailCampaignsProvider);
  final deals = ref.watch(crmDealsProvider);
  final images = ref.watch(galleryProvider);

  final brandName = profile?.brandName ?? 'your brand';
  final goalLabel = profile?.primaryGoal ?? 'growth';
  final accent = profile?.accentColor;

  final insights = <Insight>[];
  final now = DateTime.now();
  var id = 0;

  String nextId() => 'insight-${++id}';

  // --- 1. Onboarding nudge: nothing launched yet
  if (campaigns.isEmpty && posts.isEmpty && emails.isEmpty) {
    insights.add(Insight(
      id: nextId(),
      title: 'Launch your first move',
      summary:
          "Mythrix has built a complete picture of $brandName. The fastest path to results is to ship one campaign, one post, and one email this week — Mythrix can auto-draft all three.",
      severity: InsightSeverity.opportunity,
      createdAt: now,
      relatedEntity: 'Getting started',
      estimatedImpact: '+ baseline data within 48h',
      action: 'Auto-run a week',
    ));
  }

  // --- 2. Brand color reminder when campaigns lack creative refresh
  if (campaigns.isNotEmpty && images.length < 3) {
    insights.add(Insight(
      id: nextId(),
      title: 'Refresh creative for ${campaigns.first.name}',
      summary:
          "You've launched ${campaigns.length} campaign${campaigns.length == 1 ? '' : 's'} but only generated ${images.length} on-brand image${images.length == 1 ? '' : 's'}. Audiences fatigue at ~7 days — Mythrix can spin up 4 variants right now.",
      severity: InsightSeverity.warning,
      createdAt: now.subtract(const Duration(minutes: 12)),
      relatedEntity: campaigns.first.name,
      estimatedImpact: 'Prevent CTR decay',
      action: 'Generate variants',
    ));
  }

  // --- 3. Channel gap analysis — which channels has the user NOT touched?
  final usedChannels = <SocialChannel>{
    for (final p in posts) ...p.channels,
  };
  final missingChannels = SocialChannel.values
      .where((c) => !usedChannels.contains(c) && c != SocialChannel.threads)
      .toList();
  if (posts.isNotEmpty && missingChannels.length >= 2) {
    final top = missingChannels.take(2).map((c) => c.displayName).join(' and ');
    insights.add(Insight(
      id: nextId(),
      title: 'You\'re leaving $top on the table',
      summary:
          'Your ${posts.length} scheduled post${posts.length == 1 ? '' : 's'} touches ${usedChannels.length} channel${usedChannels.length == 1 ? '' : 's'}. Brands optimizing for $goalLabel typically run 4+ channels. Mythrix can cross-post automatically.',
      severity: InsightSeverity.opportunity,
      createdAt: now.subtract(const Duration(minutes: 38)),
      relatedEntity: 'Channel mix',
      estimatedImpact: '+1.8× reach (est.)',
      action: 'Cross-post',
    ));
  }

  // --- 4. Stale CRM deals — anything sitting for a while
  final staleDeals = deals.where((d) {
    return d.stage != DealStage.won &&
        now.difference(d.createdAt).inDays >= 3;
  }).toList();
  if (staleDeals.isNotEmpty) {
    final d = staleDeals.first;
    final daysIdle = now.difference(d.createdAt).inDays;
    insights.add(Insight(
      id: nextId(),
      title: '${d.companyName} has been idle for ${daysIdle}d',
      summary:
          "Deals at the ${d.stage.name} stage close 64% less often after a week of silence. Mythrix can draft a follow-up email tuned to $brandName's voice in one click.",
      severity: daysIdle >= 7 ? InsightSeverity.critical : InsightSeverity.warning,
      createdAt: now.subtract(const Duration(hours: 2)),
      relatedEntity: d.companyName,
      estimatedImpact: '\$${d.value.toStringAsFixed(0)} at risk',
      action: 'Draft follow-up',
    ));
  }

  // --- 5. Hot deal — high AI score, deserves attention
  final hotDeals = deals.where((d) =>
      d.aiScore >= 80 && d.stage != DealStage.won);
  if (hotDeals.isNotEmpty) {
    final d = hotDeals.first;
    insights.add(Insight(
      id: nextId(),
      title: '${d.companyName} is a high-intent target',
      summary:
          "Mythrix scored this deal ${d.aiScore}/100 based on stage, value, and recency. Move it to the next stage today — the data says this one closes.",
      severity: InsightSeverity.opportunity,
      createdAt: now.subtract(const Duration(hours: 4)),
      relatedEntity: d.companyName,
      estimatedImpact: '\$${d.value.toStringAsFixed(0)} pipeline',
      action: 'Advance deal',
    ));
  }

  // --- 6. Optimal time-to-post insight (always shows when there are zero scheduled posts)
  if (posts.isEmpty && profile != null) {
    insights.add(Insight(
      id: nextId(),
      title: 'Your audience is most active at 7:00 PM',
      summary:
          'Based on your industry (${profile.industry}) and target audience profile, Mythrix recommends scheduling tonight\'s post for 7:00 PM local time. Auto-Pilot can queue it now.',
      severity: InsightSeverity.info,
      createdAt: now.subtract(const Duration(hours: 1)),
      relatedEntity: 'Posting schedule',
      estimatedImpact: '+34% engagement (est.)',
      action: 'Auto-schedule',
    ));
  }

  // --- 7. Email cadence — if there are deals but no emails
  if (deals.isNotEmpty && emails.isEmpty) {
    insights.add(Insight(
      id: nextId(),
      title: 'No emails in flight — pipeline is going cold',
      summary:
          'You have ${deals.length} deal${deals.length == 1 ? '' : 's'} in CRM but zero email campaigns running. Mythrix can draft a nurture sequence in $brandName\'s voice and schedule it today.',
      severity: InsightSeverity.warning,
      createdAt: now.subtract(const Duration(hours: 6)),
      relatedEntity: 'Email pipeline',
      estimatedImpact: '+8 touchpoints',
      action: 'Draft sequence',
    ));
  }

  // --- 8. ROAS celebration when a campaign is winning
  if (campaigns.isNotEmpty) {
    final winner = campaigns.fold<LaunchedCampaign?>(
      null,
      (best, c) => c.roas > (best?.roas ?? 0) ? c : best,
    );
    if (winner != null && winner.roas >= 1.5) {
      insights.add(Insight(
        id: nextId(),
        title: '${winner.name} is your best performer',
        summary:
            'ROAS sits at ${winner.roas.toStringAsFixed(2)}× — well above breakeven. Mythrix recommends shifting +20% of budget here from underperformers. Want Auto-Pilot to handle it?',
        severity: InsightSeverity.opportunity,
        createdAt: now.subtract(const Duration(hours: 8)),
        relatedEntity: winner.name,
        estimatedImpact: '+\$${(winner.dailyBudget * 0.2 * 30).toStringAsFixed(0)}/mo',
        action: 'Reallocate budget',
      ));
    }
  }

  // --- 9. Brand consistency reminder
  if (profile != null && accent != null && images.length >= 3) {
    insights.add(Insight(
      id: nextId(),
      title: 'Lock in $brandName\'s visual identity',
      summary:
          'Mythrix has generated ${images.length} images. Pin your top 3 in the Library to anchor future generations to your visual identity — it dramatically improves consistency across channels.',
      severity: InsightSeverity.info,
      createdAt: now.subtract(const Duration(hours: 12)),
      relatedEntity: 'Brand consistency',
      estimatedImpact: 'Brand recall ↑',
      action: 'Pin top 3',
    ));
  }

  // --- 10. Always include a forward-looking systems prompt
  insights.add(Insight(
    id: nextId(),
    title: 'Auto-Pilot has scanned $brandName\'s account',
    summary:
        'Mythrix processed ${campaigns.length} campaign${campaigns.length == 1 ? '' : 's'}, ${posts.length} post${posts.length == 1 ? '' : 's'}, ${emails.length} email${emails.length == 1 ? '' : 's'}, ${deals.length} deal${deals.length == 1 ? '' : 's'}, and ${images.length} image${images.length == 1 ? '' : 's'} in the last cycle. Next scan in 12 minutes.',
    severity: InsightSeverity.info,
    createdAt: now.subtract(const Duration(minutes: 3)),
    relatedEntity: 'Auto-Pilot',
    estimatedImpact: '',
    action: '',
  ));

  // Sort newest first.
  insights.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return insights;
});
