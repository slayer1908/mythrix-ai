/// App-wide constants. Avoid magic strings/numbers throughout the codebase.
class AppConstants {
  AppConstants._();

  static const String appName = 'MYTHRIX.AI';
  static const String appTagline = 'Marketing on autopilot.';
  static const String appVersion = '0.1.0';
  static const String supportEmail = 'support@mythrix.ai';
  static const String docsUrl = 'https://docs.mythrix.ai';
  static const String statusUrl = 'https://status.mythrix.ai';

  // Storage keys
  static const String kAuthToken = 'mythrix.auth.token';
  static const String kRefreshToken = 'mythrix.auth.refresh';
  static const String kUserId = 'mythrix.auth.userId';
  static const String kThemeMode = 'mythrix.theme.mode';
  static const String kLocale = 'mythrix.locale';
  static const String kOnboardingDone = 'mythrix.onboarding.done';
  static const String kBiometricEnabled = 'mythrix.security.biometric';

  // Hive boxes
  static const String boxCache = 'mythrix_cache';
  static const String boxDrafts = 'mythrix_drafts';
  static const String boxSettings = 'mythrix_settings';

  // Limits
  static const Duration sessionIdleTimeout = Duration(minutes: 30);
  static const int maxDraftHistory = 50;
}

/// Channels MYTHRIX integrates with.
enum SocialChannel {
  instagram,
  facebook,
  twitter,
  linkedin,
  tiktok,
  youtube,
  pinterest,
  threads,
}

enum AdNetwork {
  googleAds,
  metaAds,
  tiktokAds,
  linkedinAds,
  xAds,
  microsoftAds,
  pinterestAds,
  redditAds,
}

extension SocialChannelX on SocialChannel {
  String get displayName {
    switch (this) {
      case SocialChannel.instagram:
        return 'Instagram';
      case SocialChannel.facebook:
        return 'Facebook';
      case SocialChannel.twitter:
        return 'X / Twitter';
      case SocialChannel.linkedin:
        return 'LinkedIn';
      case SocialChannel.tiktok:
        return 'TikTok';
      case SocialChannel.youtube:
        return 'YouTube';
      case SocialChannel.pinterest:
        return 'Pinterest';
      case SocialChannel.threads:
        return 'Threads';
    }
  }
}

extension AdNetworkX on AdNetwork {
  String get displayName {
    switch (this) {
      case AdNetwork.googleAds:
        return 'Google Ads';
      case AdNetwork.metaAds:
        return 'Meta Ads';
      case AdNetwork.tiktokAds:
        return 'TikTok Ads';
      case AdNetwork.linkedinAds:
        return 'LinkedIn Ads';
      case AdNetwork.xAds:
        return 'X Ads';
      case AdNetwork.microsoftAds:
        return 'Microsoft Ads';
      case AdNetwork.pinterestAds:
        return 'Pinterest Ads';
      case AdNetwork.redditAds:
        return 'Reddit Ads';
    }
  }
}
