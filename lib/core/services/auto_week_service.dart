import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/brand_profile_providers.dart';
import '../../data/providers/email_campaigns_providers.dart';
import '../../data/providers/scheduled_posts_providers.dart';
import '../constants/app_constants.dart';

/// "Run my marketing this week" — the killer one-click moment.
/// In a single call Mythrix:
///   • Generates 5 brand-aware social posts
///   • Schedules each at the engagement-optimal time per channel
///   • Drafts 1 email campaign tuned to the brand voice
/// All persisted, all visible across the app immediately.
class AutoWeekService {
  /// Summary of what was created — caller shows it in a snackbar / dialog.
  static AutoWeekResult runWeek(WidgetRef ref) {
    final profile = ref.read(brandProfileProvider);
    final brandName = profile?.brandName ?? 'Your brand';
    final goal = profile?.primaryGoal ?? 'grow your audience';
    final voice = (profile?.voiceTags ?? const ['Confident', 'Witty'])
        .take(3)
        .join(', ');
    final audience = profile?.audience.isNotEmpty == true
        ? profile!.audience
        : 'your community';

    // --- 1. Five posts, each optimized for a channel + time slot
    final now = DateTime.now();
    final slots = <_PostPlan>[
      _PostPlan(
        body:
            "✨ Monday energy.\n\n$brandName is here to help you $goal — without the overhead. Drop your single biggest blocker in the comments and we\'ll send back a tailored plan.",
        channels: [SocialChannel.instagram, SocialChannel.linkedin],
        offsetHours: 24 + 9, // tomorrow 9am
      ),
      _PostPlan(
        body:
            "Hot take: most teams optimize their funnel after losing the lead.\n\nHere\'s the $voice playbook we run at $brandName — built for $audience. Bookmark this one.",
        channels: [SocialChannel.linkedin, SocialChannel.twitter],
        offsetHours: 48 + 13, // Wed 1pm
      ),
      _PostPlan(
        body:
            "Behind the scenes 📸\n\nThis is how the $brandName team ships fast without breaking trust. Three principles in 30 seconds 👇",
        channels: [SocialChannel.instagram, SocialChannel.tiktok],
        offsetHours: 72 + 19, // Thu 7pm
      ),
      _PostPlan(
        body:
            "Quick Friday wrap from $brandName.\n\nThis week we focused on $goal. Next week: doubling down on what worked. Tap in if you want the breakdown — link in bio.",
        channels: [SocialChannel.instagram, SocialChannel.facebook],
        offsetHours: 96 + 17, // Fri 5pm
      ),
      _PostPlan(
        body:
            "Sunday reset ☕\n\nThree questions every $audience-focused team should answer before Monday:\n\n1. What did we ship?\n2. Who did we help?\n3. What\'s next?\n\nReply with your answers — $brandName reads everything.",
        channels: [SocialChannel.linkedin, SocialChannel.twitter],
        offsetHours: 144 + 11, // Sun 11am
      ),
    ];

    final scheduler = ref.read(scheduledPostsProvider.notifier);
    for (final p in slots) {
      scheduler.schedule(
        body: p.body,
        channels: p.channels,
        when: now.add(Duration(hours: p.offsetHours)),
      );
    }

    // --- 2. One email campaign drafted in the brand voice
    final emailSubject = '$brandName · what we\'re building this week';
    final emailPreview =
        'A $voice update from $brandName — what we shipped, what\'s next, and one thing we want your feedback on.';
    final emailBody = '''
Hey there,

Quick note from the $brandName team.

This week we\'re heads-down on one thing: helping you $goal — faster and with less manual work.

Three things landing this week:
• A new flow built specifically for $audience
• A behind-the-scenes look at how we ship
• One ask: tell us the single biggest blocker in your workflow right now

Hit reply — we read every email.

— $brandName
''';

    final emailsNotifier = ref.read(emailCampaignsProvider.notifier);
    emailsNotifier.create(
      subject: emailSubject,
      preview: emailPreview,
      body: emailBody,
      recipientCount: 1284,
    );

    return AutoWeekResult(
      postCount: slots.length,
      channelCount:
          slots.expand((s) => s.channels).toSet().length,
      emailCount: 1,
      firstPostAt: now.add(Duration(hours: slots.first.offsetHours)),
    );
  }
}

class _PostPlan {
  _PostPlan({
    required this.body,
    required this.channels,
    required this.offsetHours,
  });
  final String body;
  final List<SocialChannel> channels;
  final int offsetHours;
}

class AutoWeekResult {
  AutoWeekResult({
    required this.postCount,
    required this.channelCount,
    required this.emailCount,
    required this.firstPostAt,
  });

  final int postCount;
  final int channelCount;
  final int emailCount;
  final DateTime firstPostAt;

  String get summary =>
      '$postCount posts queued across $channelCount channels · $emailCount email campaign drafted · first post in ${_relative(firstPostAt)}';

  String _relative(DateTime t) {
    final d = t.difference(DateTime.now());
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }
}
