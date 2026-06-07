import '../../../data/models/campaign.dart';
import '../../constants/app_constants.dart';
import '../mock_data.dart';
import 'campaign_service.dart';

class TikTokAdsService implements CampaignService {
  @override
  AdNetwork get network => AdNetwork.tiktokAds;

  @override
  Future<bool> isConnected() async => false;

  @override
  Future<String> beginOAuth() async {
    throw UnimplementedError('TikTok OAuth not wired yet.');
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
      impressions: 1280300,
      clicks: 22130,
      spend: 1840.30,
      conversions: 198,
      revenue: 8120.00,
    );
  }
}
