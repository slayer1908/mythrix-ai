import '../../../data/models/campaign.dart';
import '../../constants/app_constants.dart';
import '../mock_data.dart';
import 'campaign_service.dart';

class LinkedInAdsService implements CampaignService {
  @override
  AdNetwork get network => AdNetwork.linkedinAds;

  @override
  Future<bool> isConnected() async => false;

  @override
  Future<String> beginOAuth() async {
    throw UnimplementedError(
        'LinkedIn Marketing Developer Program approval required first.');
  }

  @override
  Future<void> completeOAuth(String code, {String? state}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<List<Campaign>> listCampaigns() async =>
      MockData.campaigns().where((c) => c.network == network).toList();

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
      impressions: 184320,
      clicks: 3120,
      spend: 8420.00,
      conversions: 87,
      revenue: 41200.00,
    );
  }
}
