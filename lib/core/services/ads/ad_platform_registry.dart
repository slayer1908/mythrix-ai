import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_constants.dart';
import 'campaign_service.dart';
import 'google_ads_service.dart';
import 'linkedin_ads_service.dart';
import 'meta_ads_service.dart';
import 'tiktok_ads_service.dart';

/// Single source of truth for ad platform implementations.
class AdPlatformRegistry {
  AdPlatformRegistry()
      : _services = {
          AdNetwork.googleAds: GoogleAdsService(),
          AdNetwork.metaAds: MetaAdsService(),
          AdNetwork.tiktokAds: TikTokAdsService(),
          AdNetwork.linkedinAds: LinkedInAdsService(),
        };

  final Map<AdNetwork, CampaignService> _services;

  CampaignService? of(AdNetwork network) => _services[network];

  Iterable<CampaignService> get all => _services.values;
}

final adPlatformRegistryProvider =
    Provider<AdPlatformRegistry>((_) => AdPlatformRegistry());
