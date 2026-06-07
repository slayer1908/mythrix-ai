import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:logger/logger.dart';

/// Subscription tiers shipped in V1.
enum BillingPlan { free, starter, growth, scale }

extension BillingPlanX on BillingPlan {
  String get displayName => switch (this) {
        BillingPlan.free => 'Free',
        BillingPlan.starter => 'Starter',
        BillingPlan.growth => 'Growth',
        BillingPlan.scale => 'Scale',
      };

  String get priceLabel => switch (this) {
        BillingPlan.free => '\$0 / mo',
        BillingPlan.starter => '\$99 / mo',
        BillingPlan.growth => '\$299 / mo',
        BillingPlan.scale => 'Custom',
      };

  /// Inclusive feature list shown on the plan picker.
  List<String> get features => switch (this) {
        BillingPlan.free => const [
            '50 AI generations / month',
            '1 connected ad account',
            'Basic analytics',
          ],
        BillingPlan.starter => const [
            '2,000 AI generations / month',
            '3 connected ad accounts',
            'Cross-channel analytics',
            'Brand voice fine-tuning',
          ],
        BillingPlan.growth => const [
            '10,000 AI generations / month',
            'Unlimited ad accounts',
            'Auto-Pilot enabled',
            'AI image generation included',
            'Priority support',
          ],
        BillingPlan.scale => const [
            'Custom generation limits',
            'Dedicated success manager',
            'Custom integrations',
            'SLA + audit log',
            'SSO',
          ],
      };
}

/// Façade over Stripe SDK.
class BillingService {
  BillingService._();
  static final BillingService instance = BillingService._();

  final Logger _log = Logger();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final key = dotenv.maybeGet('STRIPE_PUBLISHABLE_KEY');
    if (key == null || key.isEmpty) {
      _log.w('Stripe not configured — billing runs in stub mode.');
      return;
    }

    Stripe.publishableKey = key;
    final merchant = dotenv.maybeGet('STRIPE_MERCHANT_ID');
    if (merchant != null && merchant.isNotEmpty) {
      Stripe.merchantIdentifier = merchant;
    }

    try {
      await Stripe.instance.applySettings();
      _log.i('Stripe ready.');
    } catch (e) {
      _log.e('Stripe.applySettings failed', error: e);
    }
  }

  bool get isConfigured {
    final k = dotenv.maybeGet('STRIPE_PUBLISHABLE_KEY');
    return k != null && k.isNotEmpty;
  }

  /// Begin Checkout for `plan`. In production this hits your backend, which
  /// creates a Stripe Checkout Session and returns its URL.
  Future<void> startCheckout(BillingPlan plan) async {
    if (!isConfigured) {
      if (kDebugMode) _log.w('startCheckout: Stripe not configured — no-op.');
      return;
    }
    // TODO: POST to backend /billing/create-checkout-session and redirect.
  }

  /// Open the Stripe customer portal so the user can update payment or cancel.
  Future<void> openCustomerPortal() async {
    if (!isConfigured) return;
    // TODO: POST to backend /billing/portal and redirect.
  }
}

final billingServiceProvider =
    Provider<BillingService>((_) => BillingService.instance);
final currentPlanProvider = StateProvider<BillingPlan>((_) => BillingPlan.free);
