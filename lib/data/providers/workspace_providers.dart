import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/mock_data.dart';
import '../models/campaign.dart';
import '../models/content_draft.dart';
import '../models/insight.dart';
import '../models/scheduled_post.dart';

/// V1 providers wired to MockData. Each provider has the same surface area as
/// the eventual API-backed version so the UI doesn't need to change when we
/// swap mock → live data.

final campaignsProvider = FutureProvider<List<Campaign>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 280));
  return MockData.campaigns();
});

final upcomingPostsProvider = FutureProvider<List<ScheduledPost>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 220));
  return MockData.upcomingPosts();
});

final insightsProvider = FutureProvider<List<Insight>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 240));
  return MockData.insights();
});

final draftsProvider = FutureProvider<List<ContentDraft>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 200));
  return MockData.recentDrafts();
});

/// Selected campaign for detail views — null when none chosen.
final selectedCampaignProvider = StateProvider<Campaign?>((_) => null);
