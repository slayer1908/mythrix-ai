import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/automations_providers.dart';
import '../../data/providers/brand_profile_providers.dart';
import '../../data/providers/campaigns_providers.dart';
import '../../data/providers/chat_providers.dart';
import '../../data/providers/crm_deals_providers.dart';
import '../../data/providers/email_campaigns_providers.dart';
import '../../data/providers/gallery_providers.dart';
import '../../data/providers/scheduled_posts_providers.dart';

/// Builds a single JSON bundle of every persisted artifact and copies it to
/// the clipboard. The user can paste it into any text editor to save as a
/// .json file. This avoids platform-specific download APIs and works on
/// web, desktop, and mobile.
class ExportService {
  static Map<String, dynamic> buildBundle(WidgetRef ref) {
    final profile = ref.read(brandProfileProvider);
    final drafts = ref.read(draftsStoreProvider);
    final images = ref.read(galleryProvider);
    final posts = ref.read(scheduledPostsProvider);
    final campaigns = ref.read(campaignsStoreProvider);
    final emails = ref.read(emailCampaignsProvider);
    final deals = ref.read(crmDealsProvider);
    final chats = ref.read(chatMessagesProvider);
    final automations = ref.read(automationsProvider);

    return {
      'mythrix': {
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0',
      },
      'brandProfile': profile?.toMap(),
      'drafts': drafts.map((d) => d.toMap()).toList(),
      'images': images
          .map((g) => {
                'id': g.id,
                'url': g.url,
                'prompt': g.prompt,
                'style': g.style,
                'aspect': g.aspect,
                'seed': g.seed,
                'createdAt': g.createdAt.toIso8601String(),
                'starred': g.starred,
              })
          .toList(),
      'scheduledPosts': posts.map((p) => p.toMap()).toList(),
      'campaigns': campaigns.map((c) => c.toMap()).toList(),
      'emails': emails.map((e) => e.toMap()).toList(),
      'deals': deals.map((d) => d.toMap()).toList(),
      'chats': chats
          .map((m) => {
                'id': m.id,
                'role': m.role.name,
                'text': m.text,
                'sentAt': m.sentAt.toIso8601String(),
              })
          .toList(),
      'automations': automations.map((a) => a.toMap()).toList(),
    };
  }

  /// Copies the JSON bundle to the system clipboard.
  /// Returns a summary string the caller can show in a snackbar.
  static Future<String> copyJsonToClipboard(WidgetRef ref) async {
    final bundle = buildBundle(ref);
    final jsonString = const JsonEncoder.withIndent('  ').convert(bundle);
    await Clipboard.setData(ClipboardData(text: jsonString));

    final counts = [
      '${(bundle['drafts'] as List).length} drafts',
      '${(bundle['images'] as List).length} images',
      '${(bundle['scheduledPosts'] as List).length} posts',
      '${(bundle['campaigns'] as List).length} campaigns',
      '${(bundle['emails'] as List).length} emails',
      '${(bundle['deals'] as List).length} deals',
      '${(bundle['chats'] as List).length} chat messages',
    ];
    return counts.join(' · ');
  }
}
