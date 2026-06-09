# Razorpay Setup — Take Real Money in 30 Minutes

Mythrix uses Razorpay because Stripe is invite-only in India.
This guide gets you from "demo trial" to "real customers paying real money."

---

## Why Razorpay

- ✅ India-friendly: UPI, cards, netbanking, wallets (Paytm, PhonePe)
- ✅ Accepts international cards too (for global Mythrix customers)
- ✅ No invite needed — sign up and start in 24 hours
- ✅ Free to set up
- ✅ ~2% transaction fee (similar to Stripe)
- ✅ Subscription support built in

---

## Step 1 — Create your Razorpay account (5 min)

1. Open https://razorpay.com → **Sign up free**
2. Email: any business email (use your real one — KYC later)
3. Verify mobile + email
4. You're in **Test Mode** by default — perfect for development

You can take REAL money in Test Mode by entering test cards.
When you're ready to go live, complete KYC (PAN + Aadhaar + bank account, ~24h approval).

---

## Step 2 — Create Payment Links (10 min)

From your Razorpay dashboard:

**Pro plan ($29/mo):**
1. Sidebar → **Payment Links** → **+ Create Payment Link**
2. Amount: **₹2,415** (~$29 at ₹83/USD)
3. Description: `Mythrix Pro - monthly subscription`
4. Customer info: collect email + name (so we know who paid)
5. **Notify customer:** ON (sends them receipt)
6. **Allow partial payments:** OFF
7. **Notes:** add `{"plan": "pro", "tier": "monthly"}` so webhook can identify
8. Click **Create**
9. **Copy the link URL** (looks like `https://rzp.io/i/abc123`)

**Agency plan ($99/mo):**
1. Same flow, amount: **₹8,250** (~$99)
2. Description: `Mythrix Agency - monthly subscription`
3. Notes: `{"plan": "agency", "tier": "monthly"}`
4. **Copy the link URL**

---

## Step 3 — Paste into Mythrix (1 min)

Open: `lib/core/services/razorpay_service.dart`

Replace the placeholder URLs:

```dart
static const Map<PlanTier, String> paymentLinks = {
  PlanTier.pro: 'https://rzp.io/i/YOUR_PRO_LINK',
  PlanTier.agency: 'https://rzp.io/i/YOUR_AGENCY_LINK',
};
```

Save. Commit. Push:

```powershell
cd C:\FlutterProjects\Mythrix_AI
git add lib/core/services/razorpay_service.dart
git commit -m "Wire real Razorpay payment links"
git push origin main
```

Vercel auto-deploys in ~2 min. **Pricing CTAs now open real Razorpay checkout.**

---

## Step 4 — Test it (5 min)

1. Open `https://mythrix-phi.vercel.app/#/app/pricing` in incognito
2. Sign up with a fresh email
3. Click **"Start free trial"** on Pro
4. Razorpay hosted checkout opens in a new tab
5. Test mode → use test card `4111 1111 1111 1111`, any future expiry, any CVV
6. Complete payment
7. You'll get a confirmation email + see the transaction in Razorpay dashboard

---

## Step 5 — Auto-update user plan on payment (optional, 30 min)

For now, after a user pays, you manually update their tier in Firestore.
To automate this, set up a webhook:

1. **Razorpay dashboard → Settings → Webhooks → Add webhook**
2. URL: `https://your-region.cloudfunctions.net/razorpayWebhook` (you'll create this Firebase Function next)
3. Active events: `payment_link.paid`, `subscription.charged`, `subscription.cancelled`

Then write a Firebase Function (~30 lines) that:
- Verifies the webhook signature
- Reads the `notes.plan` from the payload
- Updates `users/{customerEmail}/meta/billing` in Firestore with the new tier

Want me to write that Firebase Function next session? It's the last 5% that makes Mythrix truly autonomous.

---

## Going Live (when you're ready)

When test mode is working and you have real customers:

1. Complete KYC in Razorpay dashboard (24h)
2. Toggle **Test mode → Live mode** in dashboard
3. Re-create the payment links in Live mode (yes, separate URLs)
4. Replace the URLs in `razorpay_service.dart` again
5. Push
6. You're charging real INR/USD now

---

## Pricing notes for India

| Tier | USD | INR (₹83/USD) | INR (₹85/USD) |
|---|---|---|---|
| Pro | $29 | ₹2,415 | ₹2,465 |
| Agency | $99 | ₹8,250 | ₹8,420 |

Tip: set INR pricing to a round number that's slightly above the USD equivalent
(e.g. ₹2,499 instead of ₹2,415). Indian customers respect round numbers.

---

## Tax compliance

- **GST**: Razorpay collects 18% GST on the transaction fee, not your subscription
- **Your GST liability**: depends on your turnover. Under ₹20L/year: not required. Above: register
- **TDS**: 1% TDS deducted at source if customer is a registered business (Section 194O)
- **Talk to a CA** when you cross ₹5L/month MRR

---

## Razorpay vs alternatives

| Provider | Best for | Why |
|---|---|---|
| **Razorpay** | India-first SaaS | UPI + cards, easy setup |
| Cashfree | India SaaS | Similar to Razorpay, sometimes cheaper |
| Paddle | Selling abroad | Merchant of record, handles tax/compliance |
| Lemon Squeezy | Global SaaS | Like Paddle, simpler |
| Stripe Atlas | If you want US LLC | Costs $500 + paperwork |

For now → Razorpay. Move to Paddle/Lemon Squeezy if you outgrow it.
