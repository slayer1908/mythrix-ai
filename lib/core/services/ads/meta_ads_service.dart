import '../../../data/models/campaign.dart';
import '../../constants/app_constants.dart';
import '../mock_data.dart';
import 'campaign_service.dart';

/// Meta (Facebook + Instagram) Ads integration scaffold.
///
/// Real implementation requires a Meta App with the marketing_management
/// permission, app review approval, and a system user access token.
class MetaAdsService implements CampaignService {
  @override
  AdNetwork get network => AdNetwork.metaAds;

  @override
  Future<bool> isConnected() async => false;

  @override
  Future<String> beginOAuth() async {
    throw UnimplementedError(
        'Meta OAuth not wired yet. Add META_ADS_APP_ID + META_ADS_APP_SECRET to .env, then wire flow.');
  }

  @override
  Future<void> completeOAuth(String code, {String? state}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<List<Campaign>> listCampaigns() async {
    return MockData.campaigns().where((c) => c.network == network).toList();
  }

  @override
  Future<Campaign> createCampaign(CampaignDraft draft) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateStatus(String id, CampaignStatus next) async {
    throw UnimplementedError();
  }

  @override
  Future<CampaignMetrics> metrics(String id, {int lookbackDays = 7}) async {
    return const CampaignMetrics(
      impressions: 312100,
      clicks: 9810,
      spend: 1583.20,
      conversions: 154,
      revenue: 9870.00,
    );
  }
}
