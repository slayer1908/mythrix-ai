# MYTHRIX.AI

> Fully autonomous AI for digital marketing — content, creatives, ads, social, analytics, all on autopilot.

MYTHRIX.AI is a multi-platform Flutter application (Web + iOS + Android + Windows + macOS + Linux) that automates every aspect of a modern digital-marketing operation.

## Capabilities (V1 scope)

- **AI Content Studio** — long-form blogs, ad copy, captions, email, SEO content with brand-voice control
- **Creative Studio** — AI image & video generation, brand asset library, templates, on-brand variations
- **Social Media Scheduler** — multi-platform composer, calendar, best-time-to-post AI, bulk operations
- **Ads Manager** — unified campaign builder across Google, Meta, TikTok, LinkedIn; negative keyword automation; auto-bidding rules; A/B testing
- **Analytics** — cross-channel attribution, funnel + cohort analysis, AI insights, custom dashboards
- **SEO, Email, CRM, Automations** — full workflow surfaces
- **Brand Assets** — central library, voice guidelines, design tokens
- **Team & Permissions** — multi-seat, role-based access
- **Security** — biometric unlock, encrypted local storage, OAuth2 + PKCE, optional SSO

## Architecture

```
lib/
├── main.dart                # Entry point, env load, error guards
├── app.dart                 # Root MaterialApp.router + theme + providers
├── core/
│   ├── theme/               # Design system: tokens, themes, motion
│   ├── router/              # GoRouter config + guards
│   ├── services/            # API, storage, auth, AI, ads, social
│   ├── widgets/             # Atomic + molecule UI widgets
│   ├── constants/           # App-wide constants
│   ├── utils/               # Helpers, formatters
│   └── extensions/          # Dart/Flutter extensions
├── data/
│   ├── models/              # Domain models (immutable, json-serializable)
│   ├── repositories/        # Repository pattern wrapping services
│   └── providers/           # Riverpod providers
└── features/
    ├── auth/                # Login, signup, OAuth, biometric
    ├── onboarding/          # First-run walkthrough
    ├── dashboard/           # Mission control
    ├── content_studio/      # AI text generation
    ├── creative_studio/     # AI image / video generation
    ├── social_scheduler/    # Multi-platform scheduling
    ├── ads_manager/         # Google / Meta / TikTok / LinkedIn ads
    ├── analytics/           # Attribution, funnels, cohorts
    ├── seo/                 # Audits, keyword research
    ├── email_marketing/     # Campaigns, sequences
    ├── crm/                 # Leads, contacts, deals
    ├── automations/         # Workflow builder
    ├── brand_assets/        # Library
    ├── team/                # Members, roles, audit log
    ├── command_palette/     # Global command palette (Cmd+K)
    └── settings/            # Account, billing, integrations
```

## Tech stack

- **Flutter** 3.22+, **Dart** 3.4+
- **Riverpod** for state management
- **GoRouter** for nav with deep linking
- **Dio + Retrofit** for the API layer
- **Hive + flutter_secure_storage** for local persistence
- **fl_chart + Syncfusion** for data visualization
- **Firebase** for auth, FCM
- **Sentry** for error tracking

## Running locally

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Web
flutter run -d chrome

# iOS / Android
flutter run

# Desktop
flutter run -d macos    # or windows / linux
```

## Security posture

- All secrets read from `.env` via `flutter_dotenv` — never hard-coded
- `flutter_secure_storage` for tokens (Keychain on iOS, Keystore on Android, libsecret on Linux)
- Biometric unlock optional (`local_auth`)
- OAuth2 + PKCE for all third-party integrations
- E2E TLS, certificate pinning hooks in `core/services/api_client.dart`
- Sentry beforeSend strips PII from breadcrumbs

## Status

This is a **scaffolded V1**. The full UI/UX, design system, navigation, auth, and the
priority feature surfaces are implemented. Deep backend integrations (live API calls to
ad platforms, real AI providers) are wired through service interfaces and will be filled
in across follow-up sessions.
