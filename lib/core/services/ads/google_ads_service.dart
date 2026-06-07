import '../../../data/models/campaign.dart';
import '../../constants/app_constants.dart';
import '../mock_data.dart';
import 'campaign_service.dart';

/// Google Ads integration.
///
/// V1 scaffolding — real implementation requires a Google Cloud project,
/// a Google Ads Developer Token (apply at https://developers.google.com/google-ads/api/docs/first-call/dev-token),
/// and OAuth2 client credentials. Until those are configured the service
/// returns mocked data so the UI stays exercisable.
class GoogleAdsService implements CampaignService {
  @override
  AdNetwork get network => AdNetwork.googleAds;

  @override
  Future<bool> isConnected() async => false; // TODO: check token presence

  @override
  Future<String> beginOAuth() async {
    // TODO: implement real Google OAuth2 + PKCE.
    throw UnimplementedError(
        'Google Ads OAuth not wired yet. Add GOOGLE_ADS_CLIENT_ID + GOOGLE_ADS_CLIENT_SECRET to .env, then wire flow.');
  }

  @override
  Future<void> completeOAuth(String code, {String? state}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<List<Campaign>> listCampaigns() async {
    final all = MockData.campaigns();
    return all.where((c) => c.network == network).toList();
  }

  @override
  Future<Campaign> createCampaign(CampaignDraft draft) async {
    throw UnimplementedError(
        'createCampaign requires the Google Ads API client. Add developer token to enable.');
  }

  @override
  Future<void> updateStatus(String id, CampaignStatus next) async {
    throw UnimplementedError();
  }

  @override
  Future<CampaignMetrics> metrics(String id, {int lookbackDays = 7}) async {
    return const CampaignMetrics(
      impressions: 482300,
      clicks: 18432,
      spend: 3120.45,
      conversions: 412,
      revenue: 28940.10,
    );
  }
}
