# MYTHRIX.AI — Final Run Checklist

> **Use this when you're ready to actually run the finished app.** I'm keeping it updated each session so you have ONE place that lists every command, every check, every demo step. By the end of building, this will be your launch playbook.

---

## ⏱ Pre-flight (do once, ~5 min)

You should already have:
- ✅ Flutter SDK installed (check: `flutter --version`)
- ✅ Chrome browser
- ✅ Project at `C:\FlutterProjects\Mythrix_AI`

If `flutter --version` doesn't work, install Flutter first → [docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows).

---

## 🚀 Run the app (the 3 commands)

Open PowerShell in the project folder:

```powershell
cd C:\FlutterProjects\Mythrix_AI
flutter pub get
flutter run -d chrome
```

That's it. Chrome opens with the app running.

If `flutter pub get` complains about dependency conflicts, run:
```powershell
flutter clean
flutter pub get
```

---

## 🎬 The full demo flow (~5 min walk-through)

A scripted tour you can give a friend / investor / yourself. Hit every feature in order.

### Step 1 — Boot + login
- The browser shows a **branded boot screen** with the MYTHRIX wordmark in gradient + a sliding progress bar
- After ~1 sec → **Splash screen** with aurora background
- Auto-routes to **Login**
- Form is pre-filled with `demo@mythrix.ai` / `password123`
- Click **Sign in**

### Step 2 — Brand onboarding wizard (first time only)
- Land on the **5-step onboarding wizard**
- **Step 1**: Enter brand name (try `Brewline`), pick industry (`E-commerce`), pick accent color (try the **lime green** circle)
- **Step 2**: Pick 3–5 voice tags (try `Confident, Witty, Direct, Bold`)
- **Step 3**: Type target audience (try *"Coffee enthusiasts 28-45, urban professionals who care about origin and craft"*)
- **Step 4**: Pick primary goal (`Drive sales`) → click **Preview**
- **Step 5 (NEW celebration)**: Animated reveal of your brand card (gradient avatar with your accent color), animated lines fade in showing your voice/goal/audience summary, ending with **"Mythrix is ready"** banner
- Click **Enter Mythrix** → routes to Dashboard

### Step 3 — Mission Control dashboard ✨ The hero moment
- Greeting shows: **"Good [morning/afternoon/evening], there. Here's what MYTHRIX did for Brewline — focused on: drive sales."**
- **5 KPI cards cascade in** with a polished staggered entrance animation (each card appears 70ms after the previous)
- **Library Snapshot** glass card showing 5 hover-glowing count tiles (Drafts, Images, Scheduled, Campaigns, Chat) — counts are 0 on first run, fill up as you use the app
- Performance chart (Revenue vs Spend)
- Channel mix donut chart
- Auto-Pilot card + Insights feed
- Top campaigns table + Upcoming posts strip
- **Bottom-right corner**: a glowing **lime-green gradient orb** (your brand color!) that **gently pulses with a 2.4s breath cycle** when idle. Hover over it → pulse freezes at full strength, orb scales up. That's the Ask Mythrix chat assistant.
- **TOP-RIGHT — "Run my week with MYTHRIX" gradient button**: click this and the demo flips into autopilot. A dialog appears titled "Mythrix is running your week" with 4 cascading checklist items ("Analyzing your brand voice…" → "Drafting 5 posts tuned to your audience…" → "Picking optimal post times per channel…" → "Composing a follow-up email…"). After ~1.6s the dialog closes and a snackbar confirms: **"✨ Week queued — 5 posts queued across 4 channels · 1 email campaign drafted · first post in 33h"**. The bell badge fires 6 times in rapid succession. Open the Social Scheduler → all 5 posts are there. Open Email Marketing → the email is there. This is the moment.
- **Smart Insights feed** (right column) is no longer mocked — it reads your REAL persisted state (campaigns, posts, deals, brand profile) and surfaces 4 personalized recommendations. Examples you might see:
  - *"You\'re leaving TikTok and YouTube on the table — your 2 scheduled posts touch 2 channels. Brands optimizing for drive sales typically run 4+ channels."*
  - *"Acme Co has been idle for 5d — Deals at the qualified stage close 64% less often after a week of silence."*
  - *"Your audience is most active at 7:00 PM — Based on your industry (E-commerce) and target audience profile, Mythrix recommends scheduling tonight\'s post for 7:00 PM local time."*
  - *"Auto-Pilot has scanned Brewline\'s account — processed 1 campaign, 5 posts, 1 email, 2 deals, 5 images in the last cycle. Next scan in 12 minutes."*

### Step 4 — Chat with Mythrix
- Click the orb → slide-out chat drawer
- Type: *"Draft 3 social hooks for our new ethiopian single-origin launch"*
- Real AI response streams in (powered by free Pollinations.ai — no API key)
- Try a quick-action chip ("Summarize my campaigns")
- Hit refresh / **F5** in the browser → conversation **persists**
- Click X to close

### Step 5 — Content Studio (real AI text + auto cover image)
- Sidebar → **Content Studio**
- Pick content type (`Social post`), tone (`Witty`)
- Type prompt: *"Black Friday teaser for premium coffee subscription"*
- Click **Generate 3 variants**
- 3 variants stream in, personalized to Brewline's voice
- As text completes, a **matching AI cover image** auto-generates above the variant card (16:9, "✨ AI cover" badge)
- Scroll down to **Your drafts** — all 3 auto-saved
- Star one (gold pin), delete another
- Refresh page → drafts still there
- The auto-generated cover image is now also in Creative Studio's gallery AND in the Library → Images tab

### Step 6 — Creative Studio (real AI images)
- Sidebar → **Creative Studio**
- Pick style preset (`Cinematic`), aspect (`1:1`), variants (`4`)
- Type: *"Espresso pour, slow motion, dark moody studio lighting, steam rising"*
- Click **Generate images**
- 4 **real AI-generated images** load (Pollinations Flux model)
- Refresh page → images still there

### Step 7 — Social Scheduler
- Sidebar → **Social Scheduler**
- Calendar on the left, composer on the right
- Type post body, pick channels (Instagram + LinkedIn + TikTok)
- Click **Schedule**
- Snackbar: *"Scheduled for HH:MM (3 channels)"*
- A new **Your scheduled posts** card shows your post with relative time
- Refresh → still there

### Step 8 — Ads Manager (real campaign launch)
- Sidebar → **Ads Manager**
- Top-right: click **Launch with MYTHRIX**
- 4-step wizard: pick networks → objective → budget slider → review
- Click **Launch with MYTHRIX**
- Snackbar: *"🚀 Launched 'Brewline · Sales' across 2 networks at $250/day"*
- Top of campaigns list: violet banner *"You've launched 1 campaign — it's live below."*
- Your campaign appears at the top with brand name
- Refresh → still there

### Step 9 — Brand Assets
- Sidebar → **Brand Assets**
- Shows your full brand profile from the wizard:
  - Big gradient avatar with first letter of "Brewline"
  - Industry pill + Active pill
  - Voice tags (Confident, Witty, Direct, Bold)
  - Target audience description
  - Primary goal card with brand color
  - Color palette including your lime accent + Mythrix tokens
  - **"Edit brand"** button (reopens wizard)
  - **"Reset brand"** button (with confirmation dialog)

### Step 9.5 — Library (the central hub) ✨ Now with Export
- Top-right: **"Export all"** button (only shows if you have artifacts)
- Click it → snackbar pops: *"📋 Copied to clipboard: 3 drafts · 5 images · 1 post · 1 campaign · 1 email · 2 deals · 4 chat messages. Paste into any text editor and save as .json"*
- Open Notepad → Paste → Save as `mythrix-export.json` → You have a complete portable backup
- Sidebar → **Grow** section → **Library** (with NEW badge)
- 5 tabs at top, each with live counts: **Drafts (3) · Images (5) · Scheduled (1) · Campaigns (1) · Chat (4)**
- Search bar at top — type "coffee" to filter across the active tab
- **Images tab** — beautiful grid of every AI image you've ever generated, hover-reveal prompt overlay, star/delete actions
- **Drafts tab** — every text variant with its type/tone pills + preview
- **Campaigns tab** — every launched campaign with pause/play toggle
- This is the centerpiece pitch-deck screen. Take a screenshot of the Images tab with at least 6+ generated images.

### Step 10 — Other screens (visual tour)
Quick clicks just to see them, no interaction needed:
- **Analytics** — attribution + funnel + cohort heatmap
- **SEO** — keyword opportunities + site audit
- **Email Marketing** — click **"New campaign"** → fill subject/preview/body/recipients → Save → appears at top + persists
- **CRM** — click **"Add deal"** → enter company name + value → adds to your pipeline with auto-generated AI score → use chevron buttons to move deal through New → Qualified → Proposal → Negotiation → Won → persists
- **Automations** — recipe grid
- **Team** — members & roles
- **Settings** — account + security + integrations
- **Billing** — 4-tier plan picker

### Step 10.5 — Notifications Center ✨ NEW
- After launching a campaign / scheduling a post / saving an email / adding a deal / generating an image, look at the **bell icon** in the topbar (between the theme toggle and help icon)
- The bell changes from a thin outline to a **filled "active" icon** with a small **gradient brand-color badge** showing your unread count (1, 2, 3 … 9+)
- Click the bell → **notifications panel** drops down anchored to the bell
- Each notification shows: tinted icon tile · title · 2-line body · category + relative time ("just now", "3m ago")
- **Unread** entries have a brand-tinted background + a small accent dot on the right
- Click any notification → it marks read AND navigates you to that screen
- Click **"Mark all read"** at the top to dismiss the badge in bulk
- Hover any single notification → an X appears to dismiss individually
- **"Clear all"** at the bottom wipes the feed
- Refresh the page → notifications **persist** (stored in Hive, capped at 100 entries)

### Step 10.7 — Multi-brand workspace ✨ NEW
- **Top-left of the topbar**: a Notion-style **brand pill** with your brand's accent color + initial + name + double-chevron icon
- Click it → dropdown lists every brand you've set up + **"+ Add a brand"** at bottom
- Click another brand → instant switch — dashboard, library, campaigns, deals, everything reloads with that brand's data
- Click "+ Add a brand" → routes to the onboarding wizard to set up a new brand profile (no signup, no logout — just a new workspace)
- The Mythrix chat orb, KPI tints, library snapshot — every brand-aware UI element re-tints with the active brand's accent color

### Step 10.8 — Integrations Hub ✨ NEW
- Sidebar → Workspace → **Integrations** (NEW badge)
- 40+ platform cards across 10 categories: **Ad networks** (Google Ads, LSA, Meta, TikTok, LinkedIn, X, Microsoft, Reddit, Pinterest, Snapchat, Amazon DSP), **CRM** (HubSpot, Salesforce, Zoho, Pipedrive, monday), **Analytics** (GA4, Mixpanel, Amplitude, Segment), **Email** (Mailchimp, Klaviyo, SendGrid, Resend), **E-commerce** (Shopify, WooCommerce, BigCommerce), **Social publishing** (Meta Graph, LinkedIn Pages, TikTok Content API), **Payments** (Stripe, Paddle, PayPal), **Productivity** (Slack, Notion, Google Sheets), **Storage** (Drive, Dropbox), **AI providers** (Pollinations, Anthropic, OpenAI, Gemini)
- Filter by category chip, search by name
- Each card: brand color, name, tagline, status badge (Connected / Available / Coming soon), Phase tag, top 3 features
- Click **Connect** → tints button with the platform's color + persists to Hive. Refresh → still connected.
- Pollinations is auto-connected (free AI). The rest mock the OAuth flow and tell you which Phase they ship in.

### Step 10.9 — Automation Rules Engine ✨ NEW
- Sidebar → Grow → **Automations**
- The Revealbot-style IF-THIS-THEN-THAT engine. Pick from **7 battle-tested templates**:
  - "Pause when ROAS drops below 1.3×"
  - "Scale winners — increase budget 20% when ROAS > 3×"
  - "Kill fatigue — pause when frequency > 4 imp/user"
  - "Slow down overspend — pause when daily spend > \$500"
  - "Wake me up — Slack alert when CPA > \$80"
  - "Refresh creative — rotate when CTR drops below 1.2%"
  - "Throttle pacing — reduce budget 15% when pacing > 110%"
- One-click **Adopt** → rule starts running 24/7, persists across reload
- **New rule** button opens a builder: pick trigger (ROAS, CTR, CPA, spend, conversions, pacing, frequency, time-of-day) + threshold + action (pause, resume, change budget, switch bid strategy, notify, duplicate, rotate creative, shift budget) + optional action value
- Each rule card shows the IF-THEN summary in monospace, fire count, last-fired timestamp, toggle switch, delete

### Step 10.10 — Conversions & Tracking ✨ NEW
- Sidebar → Grow → **Conversions** (NEW badge)
- Library of 12 standard events (Purchase, Add to cart, Lead form, Schedule demo, Trial signup, etc.) — one-click add with default value + emoji
- **New conversion** opens a builder: event name, value, currency, platform (GA4, Meta CAPI, Google Ads GCLID, TikTok Events API, LinkedIn Insight Tag, Pinterest Conversions API, Reddit Pixel, Custom server-side), attribution window (1-day click, 7-day click, 1-day view, 7-day click + 1-day view, 28-day click, data-driven), server-side toggle
- Each event card shows platform badge, value, attribution window, SERVER-SIDE chip if enabled, fire count
- **Pixel & server-side setup** info card explains all the tracking layers Mythrix manages for you: client-side pixel, server-side CAPI, Consent Mode v2, Enhanced Conversions, Offline conversions, First-party data

### Step 10.11 — Per-network Ads management ✨ NEW
- Sidebar → **Ads Manager**
- Top of page: **"Your ad networks"** grid showing 11 cards — Google Ads, Google LSA, Meta, TikTok, LinkedIn, X, Microsoft, Reddit, Pinterest, Snapchat, Amazon DSP
- Each card: brand color icon, name, connection status (● Live or ○ Not connected), arrow
- Click any card → routes to `/app/ads/{networkId}` — a DEDICATED deep-dive for that network
- Network deep-dive shows:
  - Big header with network icon, name, "● Live" or "○ Not connected" pill, "New campaign" CTA
  - **Quick stats** row tuned to the network (e.g. Google Ads shows Quality Score 8.4/10; Meta shows Frequency 2.4; LinkedIn shows Lead quality 4.6/5; Amazon shows Brand-new customers 38%)
  - **Active campaigns** list with mock per-network campaigns
  - **Network-specific quick actions** — Google Ads has "Negative keyword sweep", "PMax asset refresh"; Meta has "Generate 5 ad variations", "Refresh CAPI pixel"; TikTok has "Brief 3 creators", "Sound-on hook test"; LinkedIn has "Upload account list", "Document Ad PDF"
  - **Feature grid** chips showing every native capability for that network
- If not connected: clean "Connect with OAuth" CTA card that toggles state and persists

### Step 10.12 — Audiences (Madgicx AI Audience Launcher) ✨ NEW
- Sidebar → Grow → **Audiences** (NEW badge)
- Page is organized by **funnel stage**: Cold — prospecting · Warm — engaged · Hot — high intent · Retention — buyers
- 13 pre-built audience templates across stages: Lookalike 1% Top Purchasers, Lookalike 5% Email Subscribers, Interest – Competitors, Contextual – Industry News, Video Viewers 75%+, Engaged Page Visitors, Cart Abandoners 14d, Checkout Started 7d, Lead Form Started, Existing Customers 90d, High-LTV Cohort top 10%, Win-back 180d+
- One-click **Adopt** on any template → audience appears in "Your active audiences" with reach estimate (e.g. 1.8M, 142k, 12.4k)
- Each active audience card has a **"Push to networks"** button, enabled switch, delete
- All audiences persist across reload

### Step 10.13 — AI Chat slash commands ✨ NEW
- Click the gradient chat orb → drawer opens
- Type `/` to see what's available, then any of:
  - `/help` → list all commands
  - `/week` → runs the "Run my week with Mythrix" auto-week service (5 posts + 1 email queued instantly)
  - `/post Black Friday teaser` → opens Social Scheduler with your prompt as a hint
  - `/email Q1 newsletter` → opens Email Marketing
  - `/campaign Google Ads $200` → opens Ads Manager network picker
  - `/audience` → opens Audiences module
  - `/connect Slack` → opens Integrations Hub
  - `/library` · `/automations` · `/brand` · `/conversions` — direct nav
  - `/go ads/meta-ads` → direct nav to any sub-route
- Hint text changes to "Ask Mythrix — or type / for commands"

### Step 11 — PWA install
- In the Chrome address bar (right side) — an **"Install Mythrix"** icon
- Click it → Mythrix becomes an installable native-feeling app
- Opens in its own window with no browser chrome

---

## 🐛 Common issues + fixes

| Issue | Fix |
|---|---|
| `flutter pub get` fails on a dependency | `flutter clean && flutter pub get` |
| Web build error about CORS | This is the dev server — open `http://localhost:port` directly, not via HTTPS |
| Images don't load in Creative Studio | Pollinations rate-limit (rare) — wait 30s, retry |
| Chat orb shows mock response | Pollinations endpoint blocked by your network — the router falls back to mock automatically |
| Splash screen never advances | Has a 3-second safety net — if still stuck, check console for `[Splash]` logs |

---

## 📦 What to do AFTER it's running

Once the demo works locally:

### A) Deploy to a free public URL (~3 minutes)

**One-click**: Double-click `deploy.bat` in the project root. It will:
1. Kill any running dart/flutter processes
2. Run `flutter build web --release` with PWA offline support
3. Auto-generate a `vercel.json` for SPA routing + cache headers
4. Deploy to Vercel via `npx vercel --prod --yes`
5. Print your public URL

First time only: it'll ask you to log into Vercel (browser opens). After that it's 3 minutes per deploy.

Result: `mythrix-xxx.vercel.app` — shareable with anyone.

### B) Take screenshots for your pitch deck

Capture these key moments:
1. **Boot screen** with branded gradient + progress bar
2. **Dashboard** with all KPI cards + charts + brand-personalized greeting
3. **Onboarding wizard step 2** (the voice tag picker — visually striking)
4. **Brand Assets** showing the full profile
5. **Content Studio** mid-generation (3 variants streaming)
6. **Creative Studio** with 4 real AI-generated images
7. **Ads Manager wizard step 3** (the budget slider)
8. **Chat orb open** mid-conversation
9. **Ads Manager** showing a launched campaign at the top
10. **Library** (when built) — showing all your AI-created work

### C) Show real people

Once you have screenshots OR a live URL:
- Post the link on X / LinkedIn
- DM 5 marketers you know
- Watch where their eyes go, what excites them, what confuses them
- That feedback shapes session 16, 17, 18

### D) Then come back for the next phase — the post-MVP roadmap

The local-only, no-API-key build is now a complete, demoable, market-standout product. To turn it into a real business, the next phases (in order of leverage) are:

**Phase 1 — Real authentication & multi-user (1-2 weeks)**
- Replace mock auth with Firebase Auth (Google + email/password)
- Per-user Hive box (so multiple users on the same machine don't collide)
- Add `/signup` flow with onboarding triggered post-signup
- This unlocks: real waitlist, real beta users, real metrics

**Phase 2 — Backend + cloud sync (2-3 weeks)**
- Stand up a Node/Cloudflare Worker backend with a Postgres database
- Move brand profile, drafts, campaigns, scheduled posts, deals, emails from Hive → server
- Hive becomes an offline cache; cloud is the source of truth
- This unlocks: cross-device sync, team collaboration, real analytics, never lose data

**Phase 3 — Real AI provider switching (3-5 days)**
- Add Anthropic/OpenAI/Gemini API key fields in Settings → Integrations
- Auto-route: high-stakes copy → Claude/GPT-4, fast drafts → Pollinations
- Add usage tracking + cost dashboard
- This unlocks: pricing tiers (free uses Pollinations, paid uses premium models)

**Phase 4 — Real ad platform OAuth (1-2 weeks per platform)**
- Google Ads OAuth → real campaign launch via Google Ads API
- Meta Marketing API → real Facebook + Instagram ads
- LinkedIn Marketing API → real LinkedIn campaigns
- Auto-negative-keyword feedback loop becomes REAL (currently simulated in Auto-Pilot)
- This unlocks: actually-runs-your-ads positioning vs Syntermedia

**Phase 5 — Real social publishing (1 week per platform)**
- Buffer-like OAuth flows for Instagram/LinkedIn/X/TikTok/Facebook
- Mythrix actually publishes posts at scheduled times (currently they just queue locally)
- This unlocks: replaces Buffer/Hootsuite, $15-99/mo per user

**Phase 6 — Email infrastructure (1 week)**
- SendGrid or Resend integration for real email delivery
- Contact list management
- Real opens/clicks/bounces feeding back into analytics
- This unlocks: replaces Mailchimp basic tier, $20-100/mo per user

**Phase 7 — Monetization (1 week)**
- Stripe integration
- Three tiers: Starter (free, Pollinations only), Pro ($29/mo, premium AI + 3 ad platforms), Agency ($99/mo, unlimited + team seats)
- Usage-based add-ons for ad spend > $X/mo
- This unlocks: revenue

**Phase 8 — Native apps (2 weeks each)**
- Flutter already builds iOS + Android + macOS + Windows from the same codebase
- Just need: app icons, store listings, push notifications, mobile-optimized layouts (mostly done)
- This unlocks: app store distribution, mobile-first marketers

**Phase 9 — Plugins & marketplace (1 month)**
- Let other developers build "skills" (Shopify product import, Stripe revenue insights, HubSpot deal sync)
- Take 20% rev share
- This unlocks: platform play, defensible moat

**Recommended order of operations:**
1. **Demo the current build to 10 marketers** — collect feedback before building more
2. **Phase 1 (auth) + Phase 7 (Stripe)** — get to first dollar fastest
3. **Phase 5 (social publishing)** — biggest immediate utility, lowest API complexity
4. **Phase 3 (premium AI)** — gates the Pro tier
5. **Phase 2 (backend)** — once you have paying users, sync becomes critical
6. **Phase 4 (ads)** — highest moat, but most complex; build last when you know what marketers actually want

Each phase is shippable on its own. The current build is a complete, polished, demo-ready foundation.

---

## 🗃 What's persisted right now (across browser refreshes)

| Feature | Hive box | Behavior |
|---|---|---|
| Brand profile | `cache.brand.profile.v1` | Set once in wizard, edits via Brand Assets |
| Chat history | `cache.chat.history.v1` | Every message survives reload |
| Content drafts | `cache.content.drafts.v1` | Auto-saves on every generation, star/delete |
| Generated images | `cache.creative.gallery.v1` | Real AI images persist, star/delete |
| Scheduled posts | `cache.scheduler.posts.v1` | Real schedule entries persist |
| Launched campaigns | `cache.campaigns.launched.v1` | Real launched campaigns persist |
| Notifications feed | `cache.notifications.feed.v1` | Auto-emitted on campaign/post/email/deal/image, capped at 100 |

If you want to nuke all stored state and start fresh, in Chrome DevTools → Application → IndexedDB → delete the `mythrix` database.

---

## 📝 Session log (what got added when)

- **Session 1–12**: Initial scaffold (71 Dart files, 13 feature screens, design system)
- **Session 13**: Renamed APEX.AI → MYTHRIX.AI
- **Session 14**: Pollinations.ai real AI integration (no key needed)
- **Session 15**: Hive persistence for chat
- **Session 16**: PWA manifest + branded boot screen
- **Session 17**: Gallery + drafts persistence
- **Session 18**: Onboarding wizard + brand profile
- **Session 19**: Brand Assets + brand-color tinting
- **Session 20**: Content auto-save + Schedule Post + Campaign Launch persistence
- **Session 21**: This checklist + Library screen
- **Session 22**: Auto-cover-image for Content Studio (Content + Creative loop)
- **Session 23**: Library Snapshot widget on Dashboard + real Email campaigns persistence
- **Session 24**: Real CRM deals — persistent Kanban pipeline with add/move/delete
- **Session 25**: Real Automation recipes (activate/deactivate, "Running" state) + Email + Deals tabs in Library
- **Session 26**: Polish pass — staggered KPI fade-ins, pulsing chat orb, onboarding celebration step, Export all (clipboard)
- **Session 27**: Notifications Center — persistent feed, unread badge bell, auto-emits on every campaign/post/email/deal/image event
- **Session 28 (FINAL)**: Auto-Pilot Insights Engine reads real state to generate brand-aware recommendations + "Run my week with MYTHRIX" one-click button (5 posts + 1 email queued in 1.6s with a cinematic "Mythrix is thinking" dialog)
- **Session 29 (LAUNCH READY)**: Multi-brand workspace switcher (Notion-style topbar dropdown), Integrations Hub (40+ platforms across 10 categories), Automation Rules Engine (Revealbot-style IF-THIS-THEN-THAT with 7 templates + custom builder), Conversions & Pixel module (8 platforms × 6 attribution windows + server-side toggle + GDPR/iOS 17 ready), branded Snack utility, fixed all 37 dead buttons, fixed Pollinations 403 by switching to POST /openai endpoint
- **Session 30 (COMPLETE APP)**: Per-network Ad Account screens for all 11 ad networks (Google Ads, LSA, Meta, TikTok, LinkedIn, X, Microsoft, Reddit, Pinterest, Snapchat, Amazon DSP) — each with dedicated quick stats, campaigns, network-specific actions, and feature grid. Ads Manager hub shows network cards linking to per-network deep dives. **Audiences module** (Madgicx-style AI Audience Launcher) with 13 funnel-stage templates (Cold/Warm/Hot/Retention) + custom builder. **AI chat slash commands**: `/post`, `/email`, `/campaign`, `/audience`, `/week`, `/connect`, `/library`, `/automations`, `/brand`, `/go [screen]`, `/help`
- **Session 31 (DEPLOY-READY)**: Public landing page at `/` (visible to anyone, not gated by auth) — animated gradient hero, "Marketing on autopilot" headline, real waitlist email capture form (validates + dedupes + persists to Hive), feature grid (6 cards), brand logo wall, footer. Router serves landing at `/` for everyone, redirects to login/onboarding only for `/app/*` routes. Beefed-up SEO: structured data (JSON-LD SoftwareApplication), canonical URL, robots tag, og:site_name, og:url, twitter:site, image dimensions. One-click `deploy.bat` builds + deploys to Vercel with PWA offline support, auto-generates `vercel.json` for SPA routing.

(Will keep extending each session.)
