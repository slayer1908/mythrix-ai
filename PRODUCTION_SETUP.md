# MYTHRIX.AI — Production Setup Guide

This guide walks you through everything you need to do **outside the code** to turn the V1 codebase into a live, production-ready app. Total time: 2-4 hours, all of it free or under $10.

---

## 0. Verify the code builds

```bash
cd C:\FlutterProjects\Mythrix.AI
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

The app should boot. Sign in with anything (mock auth). You're in **stub mode** — all services run with placeholder data until you complete the steps below.

---

## 1. Firebase project (15 min, free)

1. Go to [console.firebase.google.com](https://console.firebase.google.com) → **Add project** → name it **mythrix-ai**.
2. Enable: **Authentication**, **Firestore Database** (production mode), **Storage**, **Crashlytics**, **Cloud Messaging**, **Remote Config**.
3. Install the FlutterFire CLI in your terminal:
   ```bash
   dart pub global activate flutterfire_cli
   ```
4. From the project root run:
   ```bash
   flutterfire configure
   ```
   - Pick the **mythrix-ai** project.
   - Select all 5 platforms (web, ios, android, macos, windows is optional).
   - This **overwrites** `lib/firebase_options.dart` with your real keys + creates the per-platform config files.
5. In Firebase Console → **Authentication → Sign-in method**, enable: Email/Password, Google, Apple.
6. Deploy the security rules:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes,storage:rules
   ```
   (Run `firebase login` and `firebase use mythrix-ai` first if you haven't.)

Firebase is live. The app will now use real auth and start writing to Firestore.

---

## 2. Anthropic API key for Claude (5 min, ~$5)

> **Important:** Your Claude Pro subscription on claude.ai is **separate** from API access. You need a developer account at console.anthropic.com — they bill separately.

1. Go to [console.anthropic.com](https://console.anthropic.com) → sign up (separate from claude.ai).
2. Add **$5 of credit** in the Billing tab. This is plenty for testing — Sonnet 4.6 costs ~$3 per million input tokens.
3. **Settings → API Keys → Create Key**. Copy it (starts with `sk-ant-...`).
4. Open `.env` in the project root and paste it:
   ```
   ANTHROPIC_API_KEY=sk-ant-your-real-key-here
   ```
5. Restart the app. The Content Studio now generates with **real Claude Sonnet 4.6** in streaming mode.

---

## 3. OpenAI API key — optional secondary (5 min, ~$5)

1. Go to [platform.openai.com](https://platform.openai.com) → sign up.
2. Add billing, generate an API key.
3. Add to `.env`:
   ```
   OPENAI_API_KEY=sk-your-real-key-here
   ```
4. The router now load-balances between Claude (default) and GPT-4o. Switch the default by changing `AI_DEFAULT_TEXT_PROVIDER=openai`.

---

## 4. Stripe account for billing (20 min, free until first sale)

1. Sign up at [stripe.com](https://stripe.com).
2. Skip business activation for now — test mode works without it.
3. **Developers → API Keys** → copy your **Publishable key** (`pk_test_...`).
4. Add to `.env`:
   ```
   STRIPE_PUBLISHABLE_KEY=pk_test_your-key-here
   ```
5. In Stripe Dashboard → **Products** create one product per plan:
   - Starter — $99/mo
   - Growth — $299/mo
   - Scale — quote-based
6. The **real checkout flow needs a backend** to create Stripe Checkout Sessions (Stripe doesn't allow client-only secret-key calls). See [Stripe docs](https://stripe.com/docs/checkout/quickstart). For now the UI runs with a "Stripe not configured" notice.

---

## 5. Sentry for error tracking (5 min, free tier)

1. Sign up at [sentry.io](https://sentry.io) → create a Flutter project.
2. Copy the DSN.
3. Add to `.env`:
   ```
   SENTRY_DSN=https://your-dsn@sentry.io/0000000
   ```
4. Crashes in release builds now report to Sentry automatically.

---

## 6. Domain (5 min, $10-15/year)

1. Buy `mythrix.ai` on [Namecheap](https://www.namecheap.com) or [GoDaddy](https://godaddy.com).
2. In Firebase Console → **Hosting → Add custom domain** → enter `mythrix.ai` and follow the DNS instructions.

---

## 7. Deploy web build (5 min)

```bash
flutter build web --release
firebase deploy --only hosting
```

Your app is now live at `https://mythrix-ai.web.app` (and `https://mythrix.ai` once DNS propagates).

The included GitHub Actions workflow (`.github/workflows/ci.yml`) deploys automatically on every push to `main`. To activate it, add these GitHub secrets:
- `FIREBASE_SERVICE_ACCOUNT` — JSON of a Firebase service account with Hosting Admin
- `FIREBASE_PROJECT_ID` — `mythrix-ai`

---

## 8. Ad platform developer access (1-12 weeks each, approvals required)

These take real time because each platform has an approval queue. Apply early.

| Platform | Where | Time | What to apply for |
|---|---|---|---|
| **Google Ads** | [developers.google.com/google-ads/api](https://developers.google.com/google-ads/api) | 1-4 weeks | Developer Token (Standard Access) |
| **Meta Marketing** | [developers.facebook.com](https://developers.facebook.com) | 1-3 weeks | App Review for `ads_management` permission |
| **TikTok Business** | [business-api.tiktok.com](https://business-api.tiktok.com) | 1-2 weeks | Developer App + App Review |
| **LinkedIn Marketing** | [developer.linkedin.com](https://developer.linkedin.com) | 4-12 weeks | Marketing Developer Platform partnership |

Add credentials to `.env` as you get them. The ad services in `lib/core/services/ads/` will pick them up automatically.

---

## 9. App store accounts (when ready for mobile)

- **Apple Developer Program**: $99/year. Apply at [developer.apple.com](https://developer.apple.com).
- **Google Play Console**: $25 one-time. Apply at [play.google.com/console](https://play.google.com/console).

These take 1-7 days for verification.

---

## Where you stand after completing 1-7

✅ Real authentication (Firebase)
✅ Real AI content generation (Claude streaming + GPT fallback)
✅ Real local + cloud data persistence (Firestore + Hive)
✅ Real error tracking (Sentry)
✅ Real notifications (FCM + local)
✅ Real billing UI (Stripe — checkout pending backend)
✅ Live web URL with custom domain
✅ Automatic CI/CD on push

⏳ Ad platforms wait on platform approvals (step 8)
⏳ Mobile app stores wait on dev account approvals (step 9)
⏳ Backend server (Stripe Checkout Sessions + AI proxy) — next session

---

## Backend server — when you're ready

Mythrix needs a small backend for:
- Stripe Checkout Session creation (secret key cannot be in the client)
- AI key proxying (so customers don't see your key)
- Ad platform OAuth callback handling
- Webhook receivers (Stripe, ad platforms, social platforms)

Recommended stack: **Node.js + Express + PostgreSQL + Redis + Bull queue**, deployed on **Railway** or **Render** (~$10-20/mo). I can scaffold this whole thing in one focused session — say "build backend" when ready.

---

## Cost summary

| Item | Cost |
|---|---|
| Firebase (Spark plan) | Free up to 50K reads/day |
| Anthropic API ($5 trial) | Free |
| OpenAI API ($5 trial) | Free |
| Stripe | Free until first sale, then 2.9% + 30¢ |
| Sentry (free tier) | Free up to 5K events/mo |
| Domain | ~$15/yr |
| Backend hosting (Railway) | ~$10-20/mo |
| Apple Dev | $99/yr |
| Google Play | $25 once |
| **Total to launch beta** | **~$45 + $10/mo** |

That's it. Once steps 1-7 are done you have a live, paying-customer-capable product.
