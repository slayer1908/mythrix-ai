import 'package:flutter_test/flutter_test.dart';
import 'package:mythrix_ai/core/constants/app_constants.dart';
import 'package:mythrix_ai/data/models/campaign.dart';

void main() {
  group('Campaign metrics', () {
    final c = Campaign(
      id: 't',
      name: 'Test',
      network: AdNetwork.googleAds,
      objective: CampaignObjective.sales,
      status: CampaignStatus.active,
      startDate: DateTime(2026, 1, 1),
      spend: 1000,
      impressions: 100000,
      clicks: 5000,
      conversions: 200,
      revenue: 4000,
    );

    test('computes ctr, cvr, cpc, cpa, roas', () {
      expect(c.ctr, closeTo(0.05, 1e-9));
      expect(c.cvr, closeTo(0.04, 1e-9));
      expect(c.cpc, closeTo(0.2, 1e-9));
      expect(c.cpa, closeTo(5.0, 1e-9));
      expect(c.roas, closeTo(4.0, 1e-9));
    });

    test('avoids division by zero on empty metrics', () {
      final empty = Campaign(
        id: 'e',
        name: 'Empty',
        network: AdNetwork.googleAds,
        objective: CampaignObjective.sales,
        status: CampaignStatus.draft,
        startDate: DateTime(2026, 1, 1),
      );
      expect(empty.ctr, 0);
      expect(empty.cvr, 0);
      expect(empty.cpc, 0);
      expect(empty.cpa, 0);
      expect(empty.roas, 0);
    });
  });
}
