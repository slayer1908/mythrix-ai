import '../../core/constants/app_constants.dart';

enum PostStatus { draft, scheduled, publishing, published, failed }

class ScheduledPost {
  const ScheduledPost({
    required this.id,
    required this.title,
    required this.body,
    required this.channels,
    required this.scheduledFor,
    this.status = PostStatus.scheduled,
    this.mediaUrls = const [],
    this.authorName = 'MYTHRIX.AI',
    this.hashtags = const [],
    this.aiGenerated = false,
  });

  final String id;
  final String title;
  final String body;
  final List<SocialChannel> channels;
  final DateTime scheduledFor;
  final PostStatus status;
  final List<String> mediaUrls;
  final String authorName;
  final List<String> hashtags;
  final bool aiGenerated;
}
