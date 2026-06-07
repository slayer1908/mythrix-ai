# MYTHRIX.AI — Getting Started

This is a multi-platform Flutter application (Web + iOS + Android + Windows + macOS + Linux). The repo ships with the full UI/UX, design system, navigation, auth, and the priority feature surfaces fully implemented.

## Prerequisites

- Flutter 3.22 or newer
- Dart 3.4 or newer
- Xcode 15+ (for iOS / macOS), Android Studio (for Android), or a desktop toolchain (Windows / Linux)

## First-time setup

Because Flutter generates per-platform host projects (Android `android/`, iOS `ios/`, etc.), run this once in the project root before the first build. It will scaffold the host projects without touching `lib/`:

```bash
flutter create --org ai.mythrix \
  --platforms=web,ios,android,macos,windows,linux \
  --project-name mythrix_ai .
```

Then install dependencies:

```bash
flutter pub get
```

## Run

```bash
# Web (Chrome)
flutter run -d chrome

# iOS Simulator
flutter run -d "iPhone 15 Pro"

# Android Emulator
flutter run -d emulator-5554

# Desktop
flutter run -d macos     # or windows / linux
```

## Sign in

The V1 build uses a mock auth service so the entire UI is exercisable end-to-end without any backend wiring. On the sign-in screen, any email + 6+ character password is accepted. The form is pre-filled with `demo@mythrix.ai` / `password123` for convenience.

## What's wired up vs. what's mocked

**Wired up:**
- Multi-platform Flutter shell (Web + iOS + Android + Windows + macOS + Linux)
- Complete design system (dark + light themes, glassmorphism, aurora gradients, motion tokens)
- Responsive shell (sidebar on desktop, bottom nav on mobile)
- Command palette (Cmd/Ctrl+K)
- GoRouter with auth-aware redirects
- Riverpod state management
- Secure storage (Keychain / Keystore / libsecret on each platform)
- Dio API client with auth interceptor and refresh hooks
- All 13 feature surfaces with live UI: Dashboard, Content Studio, Creative Studio, Social Scheduler, Ads Manager, Analytics, SEO, Email, CRM, Automations, Brand Assets, Team, Settings

**Mocked (swappable behind service interfaces):**
- Authentication backend (mock token → real OAuth2 + PKCE)
- AI providers (mock generators → OpenAI / Anthropic / Stability / Runway)
- Ad platforms (mock data → Google Ads / Meta / TikTok / LinkedIn APIs)
- Social platforms (mock posts → Graph API / TikTok API / LinkedIn API)
- Analytics warehouse (mock series → GA4 / Mixpanel / your warehouse)

Each mocked service has a `_service.dart` interface in `lib/core/services/` — wiring real APIs swaps the implementation, not the UI.

## Where things live

```
lib/
├── main.dart                         # Bootstrap: dotenv, secure storage, error guards
├── app.dart                          # MaterialApp.router + theme + locale
├── core/
│   ├── theme/                        # Design tokens + ThemeData
│   ├── router/                       # GoRouter + auth-aware redirects
│   ├── navigation/                   # Sidebar, top bar, bottom nav, command palette
│   ├── services/                     # API client, auth, storage, mock data
│   ├── widgets/                      # Glass card, gradient button, aurora, KPI card
│   ├── constants/                    # App-wide constants and enums
│   ├── utils/                        # Formatters and helpers
│   └── extensions/                   # Context extensions
├── data/
│   ├── models/                       # Domain models
│   └── providers/                    # Riverpod providers
└── features/
    ├── auth/                         # Login + signup
    ├── onboarding/                   # Splash
    ├── dashboard/                    # Mission Control
    ├── content_studio/               # AI text generation
    ├── creative_studio/              # AI image/video generation
    ├── social_scheduler/             # Multi-platform scheduling
    ├── ads_manager/                  # Google / Meta / TikTok / LinkedIn ads
    ├── analytics/                    # Attribution, funnel, cohorts
    ├── seo/                          # Keyword research, site audit
    ├── email_marketing/              # Sequences, broadcasts
    ├── crm/                          # Pipeline, lead scoring
    ├── automations/                  # Workflow recipes
    ├── brand_assets/                 # Voice, palette, library
    ├── team/                         # Members & roles
    └── settings/                     # Account, security, integrations
```

## Continuing the build

The architecture is deliberately set up so that each future session can plug in real services without touching the UI:

1. **Wire real auth**: replace `lib/core/services/auth_service.dart` mock methods with Firebase Auth / Auth0 / your IdP.
2. **Wire real AI**: implement `OpenAiContentService`, `AnthropicContentService`, etc. behind a `ContentGenerationService` interface and inject via a Riverpod provider.
3. **Wire real ads**: implement `GoogleAdsService`, `MetaAdsService`, etc. behind a `CampaignService` interface.
4. **Wire real social**: implement `InstagramService`, etc. behind a `SocialPostingService` interface.

Each module is a self-contained directory under `lib/features/`, so you can vertically slice ownership across teams.

## Security posture

- All secrets read from `.env` via `flutter_dotenv` — never hard-coded
- `flutter_secure_storage` for tokens — Keychain on iOS, Keystore on Android, libsecret on Linux
- Biometric unlock optional via `local_auth`
- OAuth2 + PKCE is the only auth flow shipped — no password storage on device
- Sentry is wired through `main.dart` for error tracking; `beforeSend` strips PII

## License

Proprietary — all rights reserved.
