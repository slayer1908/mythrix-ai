import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../../data/models/app_notification.dart';
import '../../data/providers/campaigns_providers.dart';
import '../../data/providers/crm_deals_providers.dart';
import '../../data/providers/email_campaigns_providers.dart';
import '../../data/providers/gallery_providers.dart';
import '../../data/providers/notifications_providers.dart';
import '../../data/providers/scheduled_posts_providers.dart';

/// Mounts into the app shell as an invisible widget. Listens to every persistent
/// store and emits a notification whenever the user-visible count grows.
///
/// This keeps notifications decoupled from the individual notifiers — they
/// remain pure StateNotifiers. The bridge handles cross-cutting alerts.
class NotificationBridge extends ConsumerStatefulWidget {
  const NotificationBridge({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<NotificationBridge> createState() => _NotificationBridgeState();
}

class _NotificationBridgeState extends ConsumerState<NotificationBridge> {
  // Track last-seen counts so we only fire on growth, not on load.
  int? _lastCampaigns;
  int? _lastPosts;
  int? _lastEmails;
  int? _lastDeals;
  int? _lastImages;

  @override
  Widget build(BuildContext context) {
    // Campaign launches
    ref.listen(campaignsStoreProvider, (prev, next) {
      _lastCampaigns ??= prev?.length ?? 0;
      if (next.length > (_lastCampaigns ?? 0) && next.isNotEmpty) {
        final c = next.first;
        final networks = c.networks.map((n) => n.displayName).join(' + ');
        ref.read(notificationsProvider.notifier).push(
              kind: NotificationKind.campaign,
              title: '🚀 Campaign launched',
              body: '${c.name} is live on $networks at \$${c.dailyBudget.toStringAsFixed(0)}/day.',
              route: '/app/ads',
            );
      }
      _lastCampaigns = next.length;
    });

    // Scheduled posts
    ref.listen(scheduledPostsProvider, (prev, next) {
      _lastPosts ??= prev?.length ?? 0;
      if (next.length > (_lastPosts ?? 0) && next.isNotEmpty) {
        final p = next.first;
        final channels = p.channels.map((c) => c.displayName).join(' + ');
        ref.read(notificationsProvider.notifier).push(
              kind: NotificationKind.post,
              title: '📅 Post scheduled',
              body:
                  'Queued for $channels — going out ${_relativeWhen(p.scheduledFor)}.',
              route: '/app/social',
            );
      }
      _lastPosts = next.length;
    });

    // Email campaigns
    ref.listen(emailCampaignsProvider, (prev, next) {
      _lastEmails ??= prev?.length ?? 0;
      if (next.length > (_lastEmails ?? 0) && next.isNotEmpty) {
        final e = next.first;
        ref.read(notificationsProvider.notifier).push(
              kind: NotificationKind.email,
              title: '✉️ Email campaign saved',
              body: '"${e.subject}" — ${e.recipientCount} recipients queued.',
              route: '/app/email',
            );
      }
      _lastEmails = next.length;
    });

    // CRM deals
    ref.listen(crmDealsProvider, (prev, next) {
      _lastDeals ??= prev?.length ?? 0;
      if (next.length > (_lastDeals ?? 0) && next.isNotEmpty) {
        final d = next.first;
        ref.read(notificationsProvider.notifier).push(
              kind: NotificationKind.deal,
              title: '🤝 New deal added',
              body:
                  '${d.companyName} · \$${d.value.toStringAsFixed(0)} · AI score ${d.aiScore}/100.',
              route: '/app/crm',
            );
      }
      _lastDeals = next.length;
    });

    // Generated images
    ref.listen(galleryProvider, (prev, next) {
      _lastImages ??= prev?.length ?? 0;
      if (next.length > (_lastImages ?? 0) && next.isNotEmpty) {
        final g = next.first;
        ref.read(notificationsProvider.notifier).push(
              kind: NotificationKind.image,
              title: '🎨 New image generated',
              body: g.prompt.length > 80
                  ? '${g.prompt.substring(0, 77)}…'
                  : g.prompt,
              route: '/app/creative',
            );
      }
      _lastImages = next.length;
    });

    return widget.child;
  }

  String _relativeWhen(DateTime t) {
    final d = t.difference(DateTime.now());
    if (d.isNegative) return 'now';
    if (d.inMinutes < 60) return 'in ${d.inMinutes}m';
    if (d.inHours < 24) return 'in ${d.inHours}h';
    return 'in ${d.inDays}d';
  }
}
