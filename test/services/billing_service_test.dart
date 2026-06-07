import 'package:flutter_test/flutter_test.dart';
import 'package:mythrix_ai/core/services/billing_service.dart';

void main() {
  group('BillingPlan', () {
    test('every plan has a non-empty display name, price and features', () {
      for (final p in BillingPlan.values) {
        expect(p.displayName, isNotEmpty);
        expect(p.priceLabel, isNotEmpty);
        expect(p.features, isNotEmpty);
      }
    });

    test('scale plan is custom-priced', () {
      expect(BillingPlan.scale.priceLabel, equals('Custom'));
    });
  });
}
