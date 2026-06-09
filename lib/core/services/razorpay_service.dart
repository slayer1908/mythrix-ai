import 'package:url_launcher/url_launcher.dart';

import '../../data/models/user_plan.dart';

/// Razorpay integration for India-friendly payments (UPI + cards + netbanking).
///
/// V1 strategy: use Razorpay Payment Links (no SDK needed, no webhook needed
/// to start charging). Owner creates a payment link per tier in the Razorpay
/// dashboard, pastes URLs into the constants below. CTAs open the hosted
/// checkout in a new tab. Successful payment → Razorpay redirects user back
/// to /app/billing with `?payment_id=XXX` which we use to mark them paid.
///
/// Phase 2: replace with proper Razorpay Subscriptions API + webhook so
/// recurring billing is enforced server-side.
class RazorpayService {
  RazorpayService._();
  static final RazorpayService instance = RazorpayService._();

  /// PASTE YOUR REAL PAYMENT LINKS HERE once you have a Razorpay account.
  /// You generate them at https://dashboard.razorpay.com/app/payment-links
  ///
  /// For now these point to a placeholder so the flow doesn't break.
  static const Map<PlanTier, String> paymentLinks = {
    PlanTier.pro: 'https://razorpay.com/payment-link-pro-placeholder',
    PlanTier.agency: 'https://razorpay.com/payment-link-agency-placeholder',
  };

  /// Whether Razorpay has been configured with real payment links.
  static bool get isConfigured => paymentLinks.values
      .every((url) => !url.contains('placeholder'));

  /// Open the Razorpay checkout for the given tier in a new tab.
  /// Returns true if launched successfully.
  Future<bool> launchCheckout(PlanTier tier) async {
    final url = paymentLinks[tier];
    if (url == null) return false;
    final uri = Uri.parse(url);
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
