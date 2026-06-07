enum ContentType { socialPost, adCopy, blogPost, email, productDescription, landingPage, videoScript, smsText }

enum ContentTone { professional, friendly, witty, urgent, inspiring, authoritative, conversational, luxury }

class ContentDraft {
  const ContentDraft({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.tone,
    required this.createdAt,
    this.prompt = '',
    this.brandVoice = '',
    this.audience = '',
    this.language = 'en',
    this.starred = false,
  });

  final String id;
  final String title;
  final String body;
  final ContentType type;
  final ContentTone tone;
  final DateTime createdAt;
  final String prompt;
  final String brandVoice;
  final String audience;
  final String language;
  final bool starred;
}

extension ContentTypeX on ContentType {
  String get displayName {
    switch (this) {
      case ContentType.socialPost:
        return 'Social post';
      case ContentType.adCopy:
        return 'Ad copy';
      case ContentType.blogPost:
        return 'Blog post';
      case ContentType.email:
        return 'Email';
      case ContentType.productDescription:
        return 'Product description';
      case ContentType.landingPage:
        return 'Landing page';
      case ContentType.videoScript:
        return 'Video script';
      case ContentType.smsText:
        return 'SMS';
    }
  }
}

extension ContentToneX on ContentTone {
  String get displayName {
    switch (this) {
      case ContentTone.professional:
        return 'Professional';
      case ContentTone.friendly:
        return 'Friendly';
      case ContentTone.witty:
        return 'Witty';
      case ContentTone.urgent:
        return 'Urgent';
      case ContentTone.inspiring:
        return 'Inspiring';
      case ContentTone.authoritative:
        return 'Authoritative';
      case ContentTone.conversational:
        return 'Conversational';
      case ContentTone.luxury:
        return 'Luxury';
    }
  }
}
