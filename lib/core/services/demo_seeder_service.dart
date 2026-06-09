import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uuid/uuid.dart';

import '../../data/models/audience.dart';
import '../../data/models/automation_rule.dart';
import '../../data/models/conversion_event.dart';
import '../../data/providers/audiences_providers.dart';
import '../../data/providers/automation_rules_providers.dart';
import '../../data/providers/brand_profile_providers.dart';
import '../../data/providers/campaigns_providers.dart';
import '../../data/providers/conversions_providers.dart';
import '../../data/providers/crm_deals_providers.dart';
import '../../data/providers/email_campaigns_providers.dart';
import '../../data/providers/gallery_providers.dart';
import '../../data/providers/scheduled_posts_providers.dart';
import '../constants/app_constants.dart';

/// One-click "show me what 30 days of Mythrix activity looks like" seeder.
///
/// Populates every persisted store with realistic, brand-aware sample data so
/// first-time visitors see a populated app instead of empty cards. Designed
/// to be safe to re-run — it appends rather than wiping existing data.
class DemoSeederService {
  static const _uuid = Uuid();

  /// Result counts shown in the post-seed snackbar.
  static DemoSeedResult run(WidgetRef ref) {
    final brand = ref.read(brandProfileProvider);
    final brandName = brand?.brandName ?? 'Your brand';
    final goal = brand?.primaryGoal.toLowerCase() ?? 'grow audience';
    final voice = (brand?.voiceTags ?? const ['Confident', 'Witty'])
        .take(3)
        .join(', ');

    final now = DateTime.now();
    int posts = 0, drafts = 0, images = 0, campaigns = 0, emails = 0;
    int deals = 0, audiences = 0, rules = 0, conversions = 0;

    // ---- 1. Scheduled posts (next 7 days, mixed channels) ----
    final scheduler = ref.read(scheduledPostsProvider.notifier);
    final samplePosts = [
      ("✨ Monday energy.\n\n$brandName is here to help you $goal — without the overhead.",
       [SocialChannel.instagram, SocialChannel.linkedin], 1),
      ("Hot take: most teams optimize their funnel after losing the lead.\n\nHere's the $voice playbook from $brandName.",
       [SocialChannel.linkedin, SocialChannel.twitter], 2),
      ("Behind the scenes 📸\n\nThis is how the $brandName team ships fast without breaking trust.",
       [SocialChannel.instagram, SocialChannel.tiktok], 3),
      ("Quick Friday wrap from $brandName.\n\nThis week we focused on $goal.",
       [SocialChannel.instagram, SocialChannel.facebook], 4),
      ("Sunday reset ☕\n\nThree questions every team should answer before Monday from $brandName.",
       [SocialChannel.linkedin, SocialChannel.twitter], 6),
      ("New drop tomorrow 👀\n\n$brandName customers — keep an eye on the inbox.",
       [SocialChannel.instagram], 5),
    ];
    for (final p in samplePosts) {
      scheduler.schedule(
        body: p.$1,
        channels: p.$2,
        when: now.add(Duration(days: p.$3, hours: 9 + p.$3)),
      );
      posts++;
    }

    // ---- 2. Content drafts (recent generations) ----
    final draftsStore = ref.read(draftsStoreProvider.notifier);
    final sampleDrafts = [
      ('Black Friday teaser — short variant',
       "Black Friday's not the only day we love our customers — but it's the loudest.\n\n40% off everything tomorrow at $brandName. Set an alarm.",
       'socialPost', 'witty'),
      ('Q1 product launch announcement',
       "Big day at $brandName. The thing we've been quietly shipping for 3 months goes live tomorrow.\n\nIf you've ever wanted [X] without [Y] — this is for you.",
       'socialPost', 'authoritative'),
      ('Customer testimonial ad',
       "\"I cancelled three other tools after switching to $brandName. It's not even close.\" — Sarah, ops lead.",
       'adCopy', 'professional'),
      ('Newsletter intro — weekly',
       "Hey there,\n\nFour things from $brandName this week — pick whichever feels useful and skip the rest.",
       'email', 'conversational'),
      ('Hook for video ad',
       "If your marketing tool needs a 30-minute weekly maintenance call, you don't have a tool. You have a part-time job.",
       'adCopy', 'witty'),
    ];
    for (final d in sampleDrafts) {
      draftsStore.add(title: d.$1, body: d.$2, type: d.$3, tone: d.$4);
      drafts++;
    }

    // ---- 3. Images — Pollinations URLs (free, no key) ----
    final gallery = ref.read(galleryProvider.notifier);
    final imgPrompts = [
      'Espresso pour, slow motion, dark moody studio lighting, steam rising',
      'Modern minimal product shot, soft natural light, off-white background',
      'Lifestyle scene, young creative working from cafe window seat',
      'Abstract gradient mesh, brand colors, cinematic depth of field',
      'Hero banner — product on marble surface, top-down angle',
    ];
    final newImages = <GalleryImage>[];
    for (var i = 0; i < imgPrompts.length; i++) {
      final prompt = imgPrompts[i];
      final seed = prompt.hashCode.abs();
      newImages.add(GalleryImage(
        id: _uuid.v4(),
        url: 'https://image.pollinations.ai/prompt/${Uri.encodeComponent(prompt)}?seed=$seed&width=1024&height=1024&model=flux&nologo=true',
        prompt: prompt,
        style: 'Cinematic',
        aspect: '1:1',
        seed: seed,
        createdAt: now.subtract(Duration(days: i, hours: 3)),
      ));
      images++;
    }
    gallery.addMany(newImages);

    // ---- 4. Launched campaigns (with metrics) ----
    final campaignsStore = ref.read(campaignsStoreProvider.notifier);
    final sampleCampaigns = [
      ('$brandName — Q1 Sales', [AdNetwork.googleAds, AdNetwork.metaAds],
       CampaignObjective.sales, 250.0, 24180.0, 3128, 4.52, 218340.0),
      ('Brand search — exact', [AdNetwork.googleAds],
       CampaignObjective.sales, 80.0, 5840.0, 412, 6.21, 36260.0),
      ('Retargeting cart abandoners', [AdNetwork.metaAds],
       CampaignObjective.sales, 90.0, 6720.0, 384, 4.18, 28080.0),
      ('Reels prospecting', [AdNetwork.metaAds, AdNetwork.tiktokAds],
       CampaignObjective.awareness, 120.0, 8950.0, 124, 1.42, 12710.0),
    ];
    for (final c in sampleCampaigns) {
      final id = campaignsStore.launch(
        name: c.$1,
        networks: c.$2,
        objective: c.$3,
        dailyBudget: c.$4,
        bidStrategy: 'Target ROAS',
      );
      // Hack the metrics in via the notifier internal state update.
      final all = ref.read(campaignsStoreProvider);
      final target = all.firstWhere((x) => x.id == id);
      target.spend = c.$5;
      target.clicks = (c.$5 / 1.2).round();
      target.impressions = target.clicks * 28;
      target.conversions = c.$6;
      target.revenue = c.$8;
      campaigns++;
    }

    // ---- 5. Email campaigns ----
    final emailStore = ref.read(emailCampaignsProvider.notifier);
    final sampleEmails = [
      ('$brandName · what we shipped this week',
       'A $voice update — three things we launched, one we killed.',
       'Hey there,\n\nQuick wins from $brandName this week...', 1284),
      ('You left something behind 👀',
       'Your cart at $brandName is waiting. 15% off if you check out today.',
       'Hey there,\n\nNoticed you started checkout at $brandName...', 842),
      ('Thanks for being a $brandName customer',
       'A handwritten-style note from the founder. 90 seconds to read.',
       'Hey there,\n\nWanted to say thanks personally...', 4218),
    ];
    for (final e in sampleEmails) {
      emailStore.create(
        subject: e.$1,
        preview: e.$2,
        body: e.$3,
        recipientCount: e.$4,
      );
      emails++;
    }

    // ---- 6. CRM deals ----
    final dealsStore = ref.read(crmDealsProvider.notifier);
    final sampleDeals = [
      ('Acme Corp', 14000, DealStage.proposal),
      ('Northwave Studios', 4800, DealStage.qualified),
      ('Mariposa Hospitality', 22000, DealStage.negotiation),
      ('Helios B2B', 8200, DealStage.newLead),
      ('Atlas Health Co', 38000, DealStage.proposal),
      ('Brewline Coffee', 6700, DealStage.won),
    ];
    for (final d in sampleDeals) {
      dealsStore.add(
        companyName: d.$1,
        value: d.$2.toDouble(),
        stage: d.$3,
      );
      deals++;
    }

    // ---- 7. Audiences (5 templates) ----
    final audienceStore = ref.read(audiencesProvider.notifier);
    final sampleAudiences = [
      ('Lookalike 1% — Top Purchasers', AudienceKind.lookalike, FunnelStage.cold, 1800000, 1),
      ('Cart Abandoners — 14d', AudienceKind.retargeting, FunnelStage.hot, 12400, 1),
      ('Existing Customers — Last 90d', AudienceKind.custom, FunnelStage.retention, 18400, 1),
      ('Video Viewers 75%+ — 30d', AudienceKind.retargeting, FunnelStage.warm, 84000, 1),
      ('Interest — Competitors + Adjacent', AudienceKind.interest, FunnelStage.cold, 24000000, 1),
    ];
    for (final a in sampleAudiences) {
      audienceStore.add(
        name: a.$1,
        kind: a.$2,
        stage: a.$3,
        size: a.$4,
        percentMatch: a.$5,
      );
      audiences++;
    }

    // ---- 8. Automation rules ----
    final rulesStore = ref.read(automationRulesProvider.notifier);
    final sampleRules = [
      ('Pause underperformers', RuleTrigger.roasBelow, 1.3, RuleAction.pause, null),
      ('Scale winners +20%', RuleTrigger.roasAbove, 3.0, RuleAction.increaseBudgetPct, 20.0),
      ('Kill fatigue', RuleTrigger.audienceFatigue, 4.0, RuleAction.pause, null),
      ('Slack alert on high CPA', RuleTrigger.cpaAbove, 80.0, RuleAction.notifySlack, null),
    ];
    for (final r in sampleRules) {
      rulesStore.add(
        name: r.$1,
        trigger: r.$2,
        triggerValue: r.$3,
        action: r.$4,
        actionValue: r.$5,
      );
      rules++;
    }

    // ---- 9. Conversion events ----
    final conversionStore = ref.read(conversionsProvider.notifier);
    final sampleConversions = [
      ('Purchase', ConversionPlatform.metaCapi, 75.0, true),
      ('Add to cart', ConversionPlatform.metaCapi, 0.0, false),
      ('Lead form submit', ConversionPlatform.googleAdsClickId, 25.0, true),
      ('Schedule demo', ConversionPlatform.linkedinInsight, 100.0, true),
    ];
    for (final c in sampleConversions) {
      conversionStore.add(
        name: c.$1,
        platform: c.$2,
        value: c.$3,
        serverSide: c.$4,
      );
      conversions++;
    }

    return DemoSeedResult(
      posts: posts,
      drafts: drafts,
      images: images,
      campaigns: campaigns,
      emails: emails,
      deals: deals,
      audiences: audiences,
      rules: rules,
      conversions: conversions,
    );
  }
}

class DemoSeedResult {
  DemoSeedResult({
    required this.posts,
    required this.drafts,
    required this.images,
    required this.campaigns,
    required this.emails,
    required this.deals,
    required this.audiences,
    required this.rules,
    required this.conversions,
  });
  final int posts, drafts, images, campaigns, emails, deals, audiences, rules, conversions;

  String get summary =>
      '$campaigns campaigns · $posts posts · $emails emails · $deals deals · $audiences audiences · $images images · $drafts drafts · $rules rules · $conversions conversions';
}
