<a id="readme-top"></a>

<div align="center">

# RexOne Mobile

### Start from One. Not from Zero. A disciplined Flutter client, built to turn a powerful foundation into a seamless mobile product experience.

A production-grade mobile foundation for authenticated native applications. Identity, payments, access control, media, AI, real-time delivery, push notifications, product analytics, in-app updates, localization, client telemetry, and reusable design primitives meet here—not as disconnected demos, but as one cohesive, modular mobile application.

Built under the same creed as RexOne Core and RexOne Web: **Start from One. Not from Zero. Clear in thought, exact in structure, simple in use, and strong enough to endure what comes after launch.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![GetX](https://img.shields.io/badge/GetX-4.7-8A2BE2)](https://pub.dev/packages/get)
[![Drift](https://img.shields.io/badge/Drift_SQLite-Type--Safe-00599C?logo=sqlite&logoColor=white)](docs/CLIENT_DATABASE.md)
[![Sponsor rex-9](https://img.shields.io/badge/Sponsor-%E2%9D%A4-ea4aaa?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/rex-9)
[![Web Demo](https://img.shields.io/badge/Web_Demo-rexone.rex9.me-FF2238?logo=firefox&logoColor=white)](https://rexone.rex9.me)
[![CI](https://github.com/rex-9/rexone_mobile/actions/workflows/test.yml/badge.svg)](https://github.com/rex-9/rexone_mobile/actions/workflows/test.yml)

**Typed · Modular · Localized · Observable · Push-ready · Analytics-enabled · API-driven · Fully Tested**

[Live Web Demo ↗](https://rexone.rex9.me) · [Explore the client](#feature-map) · [Who it is for](#who-rexone-mobile-is-for) · [Ecosystem Architecture](ECOSYSTEM.md) · [Development Law](LAW.md) · [Agent Governance](https://github.com/rex-9/rexone-core/blob/dev/AGENTS.md) · [Run it locally](#-quick-start) · [Architecture](#architecture) · [Documentation Hub](docs/README.md)

</div>

---

### 🏛️ Unified Ecosystem & Constitutional Directives

| Resource                  | Purpose & Canonical Specification                                                                                                                                                                                                                                                                                       |
| :------------------------ | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **🏛️ Unified Ecosystem**  | Complete cross-platform architecture, feature parity matrix, and communication protocols between Core, Web, and Mobile: **[Ecosystem Architecture](https://github.com/rex-9/rexone-core/blob/dev/ECOSYSTEM.md)** and **[Visual Walkthrough](https://github.com/rex-9/rexone-core/blob/dev/docs/VISUAL_WALKTHROUGH.md)** |
| **📜 Constitutional Law** | Non-negotiable architecture, design system, and state laws: **[LAW.md](LAW.md)** _(Zero exceptions)_                                                                                                                                                                                                                    |
| **🤖 Operational Agent Governance** | Autonomous agent rules, secret isolation, and documentation synchronization: **[AGENTS.md](https://github.com/rex-9/rexone-core/blob/dev/AGENTS.md)** |
| **🗄️ Client Database**    | Drift SQLite local-first architecture and schema mirroring: **[`docs/CLIENT_DATABASE.md`](docs/CLIENT_DATABASE.md)**                                                                                                                                                                  |
| **📖 Master Documentation Hub** | Native subsystem architecture, CLI tools, and E2E testing: **[`docs/README.md`](docs/README.md)**                                                                                                                                                                                     |

---

## Why RexOne Mobile?

A capable backend and a polished web app are only parts of the whole product. Mobile is not a website wrapped in a webview—it is an independent, first-class native client that must navigate operating system lifecycles, volatile network disconnects, hardware audio focus, push notification routing, app store version migrations, real-time socket events, platform sessions, biometric/passcode verification, and structured error telemetry.

RexOne Mobile exists so that work does not have to be reinvented or rebuilt from scratch for every mobile product built on RexOne Core.

### The Purpose: Start from One. Not from Zero.

Instead of burning money and compute wasting AI tokens on weak, fragmented mobile boilerplate or having to rebuild cross-platform contracts, push notifications, and state architecture again and again for every product, RexOne Mobile provides a sovereign, production-grade Flutter foundation.

### Discipline-Driven Development (DDD): The Unvarnished Mobile Truth

RexOne Mobile pioneers **Discipline-Driven Development (DDD)** for native mobile engineering. In an era where AI agents can vomit thousands of lines of Flutter code in seconds, the bottleneck is never rendering a UI—it is **preserving native performance, managing hardware lifecycles, and preventing widget-tree chaos**.

> *You bring the idea. AI writes the code. RexOne keeps both of you from destroying the foundation.*

#### Fearless Mobile Realities Others Hesitate to Reveal:
1. **The Mobile AI Vibe-Coding Catastrophe**: Unguided AI coding agents dump API calls, state manipulation, audio focus, and storage I/O directly into monolithic `build()` methods. Within two iterations, hot reload crawls, memory leaks proliferate, and the app crashes on the first network hiccup. Discipline-Driven Development enforces strict separation: Presentation (widgets), Business Logic (controllers), and Data (services & models).
2. **The Webview Wrapper Cop-Out**: Wrapping a responsive website in a webview shell and calling it an "iOS and Android app" is lazy, deceptive, and disrespectful to users. Real mobile experiences demand native 60fps rendering, hardware-accelerated media streaming, and offline-first SQLite persistence (Drift) that operates seamlessly in airplane mode.
3. **The Mobile BaaS Trap**: Direct-to-database mobile SDKs expose client apps to severe security vectors, runaway cloud query costs, and zero offline durability. Real mobile architecture communicates with a sovereign, authenticated API core.
4. **Zero Deprecation Shims & Zombie Code**: Retaining dead screens, abandoned controllers, or stale model fields is cowardice. Under Constitutional Law U14, replaced code is eliminated completely.
5. **100% Free Sovereignty**: Unlike commercial Flutter starter kits charging hundreds of dollars or locking push notifications and offline sync behind paid licenses, RexOne Mobile is 100% free, MIT/open, and sovereign.

### 📊 Architectural Comparison: Why RexOne Wins

| Dimension / Capability | 🛡️ **RexOne Sovereign Trinity** | 📦 **Next.js Full-Stack Boilerplates** | 🔥 **Firebase / Cloud Serverless** | 🪤 **Supabase / BaaS Starter Kits** | 🚂 **Rails & Laravel Monoliths** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Architectural Model** | ✅ **Sovereign Tri-Platform**: Rails 8 API + React 19 SPA + pure Flutter 3 native client | ❌ **Node Monolith**: API, DB, jobs & DOM crammed into 1 fragile runtime | ❌ **Serverless Spaghetti**: Disconnected Cloud Functions + NoSQL Firestore | ⚠️ **Client-Heavy BaaS**: Direct client DB queries + scattered edge functions | ⚠️ **HTML Monolith**: Server-rendered HTML with Turbo/Livewire |
| **Native Mobile App** | ✅ **Native 60fps Flutter**: Shared contracts, biometrics, hardware media & push | ❌ **None or Webview Shell**: Sluggish Capacitor/Cordova wrapper | ⚠️ **Fragmented SDKs**: Direct NoSQL queries from mobile with zero encapsulation | ⚠️ **Raw Client SDK**: Mobile apps directly expose database tables via client key | ⚠️ **Turbo / Webview**: Web pages wrapped in a native navigation shell |
| **Offline-First Durability** | ✅ **Drift SQLite (`rexone_offline`)**: Schema mirroring, offline subtitles & AES-256 saves | ❌ **None**: Application breaks entirely on network disconnect | ⚠️ **Flaky Document Cache**: Primitive document cache prone to sync desync | ⚠️ **No Relational Offline**: Unreliable offline sync across foreign keys | ❌ **None**: Server-rendered pages require constant connectivity |
| **Database Integrity** | ✅ **Strict Relational PostgreSQL**: Foreign keys, ACID, UUIDs, soft-deletes | ⚠️ **ORM Inconsistencies**: Serverless connection pool limits on Prisma/Drizzle | ❌ **NoSQL Hell**: No joins, no cascading deletes, data duplication nightmare | ✅ **PostgreSQL**: Relational integrity via managed Postgres instance | ✅ **PostgreSQL / MySQL**: Mature relational ORM (ActiveRecord / Eloquent) |
| **Background Processing** | ✅ **Solid Queue (Fibers + Threads)**: Workload pooling, recurring cron, zero Redis costs | ❌ **Serverless Timeouts**: Forced into third-party Inngest, QStash, or Celery ($$$) | ❌ **Execution Timeouts**: Severe execution limits, cold starts & high invocation bills | ⚠️ **Edge Functions**: Strict 10s CPU limits, no persistent background workers | ⚠️ **Redis Dependency**: Requires external Redis broker & extra hosting RAM |
| **Real-Time Delivery** | ✅ **Native Action Cable**: Persistent WebSockets, auto-reconnect & binary STT/TTS | ❌ **Broken on Serverless**: Forced into expensive Pusher / Ably tiers ($$$) | ⚠️ **Firestore Listeners**: Pay-per-document-read billing nightmare under active polling | ⚠️ **Supabase Realtime**: Row-level broadcast, high connection pricing tiers | ⚠️ **External Broker**: Requires Redis/Reverb/Soketi daemon configuration |
| **Object Storage** | ✅ **Self-Hosted Garage S3**: High-performance local S3, zero egress bills | ❌ **Vendor Cloud**: AWS S3 / Cloudflare R2 egress fees | ❌ **Google Cloud Storage**: Proprietary bucket pricing & steep download egress fees | ⚠️ **Proprietary Storage**: Vendor-locked BaaS pricing ladders | ⚠️ **ActiveStorage / Flysystem**: Tied to third-party cloud S3 bucket bills |
| **AI Workflows & Speech** | ✅ **Durable Queued AI**: Chunked streaming, 16kHz live STT, binary MP3 TTS | ⚠️ **Edge Timeouts**: LLM streams crash on cold starts or Vercel limits | ❌ **Synchronous Timeouts**: Long-running LLM inferences hit function deadlines | ❌ **Client Leaks**: Client-side API keys or basic Edge Function calls | ⚠️ **Basic Wrappers**: Simple synchronous chat endpoints |
| **Anti-Vibe Governance** | ✅ **Constitutional Law (`LAW.md`)**: Laws U14/U15 stop AI tech debt and zombie code | ❌ **Unguided Vibe-Coding**: Fragile abstractions, dead shims & runaway debt | ❌ **Scattered Cloud Logic**: Code fragmented across dozens of uncoordinated functions | ❌ **RLS Spaghetti**: 100+ line SQL security policies prone to data leaks | ⚠️ **Conventions Only**: No explicit constitutional AI agent rules |
| **Cost & Sovereignty** | ✅ **100% Free & Open (MIT)**: Zero paywalls, zero "Pro" upsells, sovereign VPS deploy | ❌ **$199–$499 Paid License**: Features gated behind tier paywalls | ❌ **Google Vendor Trap**: Massive cloud bills as user volume scales ($5k–$20k/mo) | ❌ **Monthly Cloud Lock-in**: Free tier lulls you into $5,000/mo hostage bill | ❌ **$299–$799 Paid License**: Commercial starter kit paywalls (Jumpstart, Spark) |

RexOne Mobile stops mobile chaos decisively:
- **First-Class Mobile, Not a Webview Shell**: Built with pure Flutter 3 & Dart Clean Architecture (Presentation, Business Logic, and Data layers) orchestrated by reactive GetX.
- **Local-First Offline Resilience**: Fully backed by a local **Drift (Type-safe SQLite)** database (`rexone_offline`), ensuring instant media playback, offline subtitles, and zero network-choke even when completely disconnected.
- **The Foundation Bends Around the Product**: RexOne Mobile provides native device plumbing (biometrics, camera, audio focus, push, background tasks, AES-256-GCM sandbox encryption) while leaving your product UI and domain completely unencumbered.

Feature modules, shared services, models, bindings, design primitives, and telemetry pipelines have exact and deliberate responsibilities:

- **Modules** own a product feature end to end — pages, controllers, and (when needed) that feature's HTTP client — behind a single barrel export.
- **Shared services** are thin, single-responsibility clients for transport that is not feature-owned: HTTP, Action Cable, Firebase, OneSignal, storage, and client logs.
- **Design primitives** enforce consistent spacing, typography, and theme tokens across light and dark modes.
- **Observability listeners** automatically capture uncaught Flutter and platform errors and ship structured diagnostic payloads to RexOne Core's client log store.

The client is designed to **bend around the product**, never to make the product kneel before the foundation.

## Who RexOne Mobile is for

RexOne Mobile is built for Flutter teams, founder-engineers, and agencies creating Android and iOS products on RexOne Core that need native device integration without fragmenting the ecosystem's identity, commerce, notification, and API contracts.

It is a particularly good fit when a mobile product needs several of these capabilities to work together:

- Complete identity, confirmation, recovery, Google sign-in, and platform-isolated sessions.
- Stripe checkout, subscriptions, purchases, and entitlement-aware experiences.
- Push and in-app notifications with deep-link handling and conversion analytics.
- Queued AI responses and real-time operation updates that survive navigation or app backgrounding.
- Camera, gallery, microphone, permissions, app-version checks, and device-aware telemetry.
- Shared localization, device-local date and time presentation, themes, and reusable interface primitives.

RexOne Mobile is not a collection of disconnected Flutter screens or a replacement for product-specific UX. It is the reference Android and iOS client for RexOne Core, leaving each product free to define its own domain and experience.

## What you get

- **One cross-platform client architecture:** Android and iOS share typed models, feature modules, routing, localization, and lifecycle behavior.
- **Native delivery foundations:** permissions, push notifications, deep links, version upgrades, media input, and device telemetry are already coordinated.
- **Durable product flows:** authentication, commerce, AI, profile, and notification behavior follow the same Core contracts as RexOne Web.
- **Centralized infrastructure:** API handling, socket reconnection, analytics, logging, storage, and device orchestration remain outside individual pages.
- **A customizable design system:** reusable components and tokens support product-specific interfaces without discarding the application structure.

---

## The philosophy

RexOne Mobile follows the same doctrine as the ecosystem it serves:

> **Clarity before cleverness. Precision before haste. Simplicity without weakness. Strength without spectacle.**

The difficult part of mobile engineering is rarely rendering another screen. It is preserving a codebase that remains understandable when routes multiply, background workers fire, push payloads arrive while the app is backgrounded, API contracts evolve, and multiple developers build in parallel.

So the ambition was never to build the most complex state tree possible.

It was to build a **clear mobile foundation**—strong enough to carry ambitious products, flexible enough to surrender its shape to them, and disciplined enough that any developer can trace data from interaction to API and back without archaeology.

---

## Feature map

| Foundation             | What is ready                                                                           | Details                                                              |
| ---------------------- | --------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| **Identity**           | Email/password flow, OTP verification, recovery, Google sign-in, platform sessions      | [Authentication & security](#authentication--security)               |
| **Profile & IAM**      | Profile settings, camera/gallery avatar upload, and 3-tier RBAC admin hierarchy         | [Profile & IAM Hierarchy](#profile--iam-hierarchy)                   |
| **Push Notifications** | OneSignal push messaging, permission management, user tag syncing, and click routing    | [Push & Analytics](#push-notifications--analytics)                   |
| **Product Analytics**  | Firebase Analytics screen tracking, auth lifecycle events, and telemetry                | [Push & Analytics](#push-notifications--analytics)                   |
| **In-App Upgrades**    | Splash checks `/v1/client/versions/current` and shows force or skippable update dialogs | [Version Upgrader](#in-app-version-upgrader)                         |
| **Commerce**           | Products, Stripe Checkout WebView, coupons, subscriptions, and cancel/resume workflows  | [Payments & entitlements](#payments--entitlements)                   |
| **Media & Offline**    | Progressive A/V streaming, SRT subtitles, synced lyrics, Drift SQLite, and AES-256 saves | [Media & offline playback](#media--offline-playback)                 |
| **AI Assistant**       | Non-blocking queued chat, persistent room history, and Action Cable notifications       | [AI capabilities & Speech](#ai-capabilities--speech)                 |
| **Speech (TTS & STT)** | Live 16kHz PCM voice streaming with level bars and direct binary MP3 TTS playback      | [AI capabilities & Speech](#ai-capabilities--speech)                 |
| **Real Time**          | Action Cable WebSocket client, subscription channels, and global toast dispatching      | [Real-time delivery](#real-time-delivery)                            |
| **Observability**      | Flutter and platform error capture with automated client log delivery to RexOne Core    | [Client observability](#client-observability--telemetry)             |
| **Design System**      | Centralized design tokens, theme extensions, custom components, and light/dark modes    | [Design system](#design-system)                                      |
| **Localization**       | English and Burmese with dynamic runtime switching and `X-Locale` backend sync          | [Localization](#localization)                                        |
| **Governance**         | Constitutional Architecture (LAW.md) & AI Agent Operational Rules (AGENTS.md)          | [LAW.md](LAW.md) · [AGENTS.md](https://github.com/rex-9/rexone-core/blob/dev/AGENTS.md) |
| **Testing (E2E)**      | Real on-device automated user journey specs via Flutter Integration Test Driver         | [Quality & testing](#-quality--automated-testing)                   |
| **Quality**            | Strongly typed Dart models, analyzer compliance, and automated test suite               | [Quality & testing](#-quality--automated-testing)                   |

---

## Architecture

RexOne Mobile keeps framework concerns explicit, responsibilities separated, and external providers isolated.

```mermaid
flowchart LR
    User[User & Gestures] --> UI[Module Pages & Design Components]
    UI --> Controllers[Module Controllers]
    Controllers --> FeatureSvc[Feature Services]
    Controllers --> SharedSvc[Shared Services]
    FeatureSvc --> API[GetConnect HTTP Client]
    SharedSvc --> API
    API --> Core[RexOne Core API]

    Core <-->|Action Cable| Socket[Socket Service]
    Socket --> SocketCtrl[Socket Controller]
    SocketCtrl --> Controllers
    SocketCtrl --> UI

    OneSignal[OneSignal Push Service] --> Controllers
    Controllers --> Analytics[Firebase Analytics]
    Runtime[Flutter & Platform Errors] --> LogService[Log Service]
    LogService --> Core
```

### Layer Boundaries:

- `lib/modules/` owns product features end-to-end. Each module keeps its pages, controllers, and optional feature service together behind a single barrel export (`auth.dart`, `payment.dart`, `media.dart`, …).
- `lib/controllers/` holds only app-wide coordinators that do not belong to one feature (e.g. `SocketController`).
- `lib/services/` holds shared infrastructure: HTTP (`ApiService`), Action Cable, Firebase Analytics, OneSignal, storage, device permissions, and client logs.
- `lib/database/` encapsulates the type-safe Drift SQLite database (`rexone_offline`) and local DAOs.
- `lib/design/` centralizes design tokens, theme definitions, extensions, and reusable UI components.
- `lib/bindings/` handles centralized dependency injection for shared services and permanent controllers. Route-scoped controllers are bound on their respective `GetPage`.
- `lib/models/` contains strongly typed JSON:API models, pagination metadata (`PaginationMeta`, `PaginatedResponse`), and response envelopes.
- `lib/locales/` contains multi-language translations and runtime dictionary updates.
- `lib/config/` and `lib/constants/` manage environment definitions, typed JSON keys (`JsonKeys`), and log constants.

---

## The client in detail

### Authentication & security

- **Smart Email Discovery**: Automatically checks user registration and confirmation state via `GET /peek`.
- **6-Digit Password**: In-memory password handling for sign-in and registration (credentials never leak to disk or route arguments).
- **Unconfirmed Drop-off Recovery**: Returning unconfirmed users route directly to email confirmation OTP, bypassing credentials setup.
- **Escalating Attempt Protection**: Reactive password retry limits and cooldown counters driven dynamically by RexOne Core.
- **Email Confirmation**: 6-digit email OTP verification with countdown-guarded resend capabilities.
- **Google Sign-In**: Native Google OAuth flow with RexOne Core challenge token support for first-time signups.
- **Active Session Enforcement**: Sends `X-Platform: android` or `X-Platform: ios` so Core maintains an isolated active session for each native platform.
- **Session Replacement Handling**: Detects active session invalidation and gracefully routes the user to sign-in with localized feedback.

### Profile & IAM Hierarchy

- Own feature module at `lib/modules/profile/` with route-scoped `ProfileController` on `/profile`.
- Camera and gallery avatar selection via `image_picker` guarded by shared `PermissionService`.
- **Three-Tier Administrative RBAC**: Enforces `super_admin` (full authority), `admin` (domain operations, excluding `users` and `iam`), and partial admins (`*_admin`, where permissions grant access to both standard and admin endpoints).

### Push notifications & Analytics

- **OneSignal Push**: Native push messaging for Android and iOS with user tag synchronization hooked into auth lifecycle and deep-link click routing.
- **Firebase Analytics**: Central navigation tracking emits `view_page` from `GetMaterialApp.navigatorObservers` with `platform: android` or `platform: ios`. User identity is synced via opaque user ID; personal data is never sent to Analytics.

### In-App Version Upgrader

- Checks `/v1/client/versions/current` during app startup via `VersionService` using canonical `AppInfo` metadata.
- `must_update`: Handled exclusively by the sovereign full-screen `SplashPage` blocking view with `PopScope(canPop: false)` and direct store handoff.
- `update_required`: Prompted non-blockingly on `HomePage` via `AppDialog.update` with "Later" and "Update" options.

### Payments & entitlements

- Product catalogue with one-time and recurring pricing and pagination support.
- Promo & referral coupon validation (`POST /v1/payment/coupons/validate`) with real-time discount calculation and localized pricing.
- In-app Stripe Checkout handoff via WebView (`webview_flutter`). Zero-amount checkouts bypass Stripe and provision immediate entitlement access.
- Subscription state management (Active, Scheduled for Cancellation, Expired) with destructive confirmation guards.

### Media & offline playback

- Unified feature module at `lib/modules/media/` with a shared `MediaPlaylistPage`, dual players, and offline caching:
  - **Video (`better_player`)**: Hardware-accelerated 16:9 inline viewport, audio focus management (`setMixWithOthers(false)`), low-latency buffer tuning, 100MB chunk disk caching, and gap-bridged SRT closed captions (`SrtHelper.bridgeSmallGaps`).
  - **Audio (`just_audio`)**: Background playback with lock-screen Now Playing controls, persistent mini player, and Apple Music-style synced lyrics from SRT tracks.
  - **Local-First Drift SQLite**: Backed by a local **Drift (SQLite)** database (`rexone_offline`, documented in [`docs/CLIENT_DATABASE.md`](docs/CLIENT_DATABASE.md)). Downloaded media always plays from local decrypted storage even when online, delivering instant startup.
  - **Airplane Mode Resilience**: When offline, the playlist queries Drift SQLite, presenting downloaded media with offline thumbnails and subtitles.
  - **Security & Background Transfers**: AES-256-GCM sandbox encryption, single icon-space progress controls, storage accounting, and background execution via `background_downloader` with Android foreground notifications and iOS Live Activity support.

### AI capabilities & Speech

- **Conversational AI Chat**: Non-blocking queued AI chat backed by RexOne Core (DeepSeek / Gemini), multi-room management, persistent history, and live thinking indicators.
- **Live Voice Dictation (STT)**: Microphones stream normalized 16-bit PCM chunks to Core's ActionCable `SpeechLiveChannel` with interactive `VoiceLevelBars` wave visualization.
- **Text-to-Speech (TTS) Playback**: Direct binary audio stream playback via `just_audio` without base64 overhead, dynamically linking generated audio assets to chat bubbles.

### Real-time delivery

- Real-time WebSocket connection to RexOne Core via Action Cable (`SolidCable`).
- Auto-reconnect and token refresh on authentication.
- Centralized `SocketController` dispatches notifications and manages global toast feedback.

### Client observability & telemetry

- Global error capture through `FlutterError.onError` and `PlatformDispatcher.instance.onError`.
- Structured diagnostic payloads (message, stack trace, device metadata, OS version, app version) delivered directly to RexOne Core's `POST /v1/client/logs`.

### Design system

- Centralized design entry point via `import 'package:rexone_mobile/design/design.dart';`.
- Design tokens: `Design.spacing`, `Design.typography`, `Design.icons`, and `Design.timers`.
- Theme extensions (`context.colors`, `context.typo`) supporting cohesive light and dark themes.
- Reusable components: `AppButton`, `AppInputField`, `AppPasswordField`, `AppDialog`, `AppLoading`, `AppPage`, and `AppSnackbar`.

### Localization

- Fully localized into:
  - 🇬🇧 **English (`en_US`)**
  - 🇲🇲 **Burmese (`my_MM`)**
- Complete parity across all user-facing texts with dynamic runtime GetX translation reload and automated `X-Locale` backend header sync.

---

## ⚡ Quick Start

### Prerequisites

- **Flutter SDK**: `>= 3.11.5`
- **Dart SDK**: `>= 3.11.5`
- **Android Studio** / **VS Code** with Flutter extensions
- **Xcode** (for iOS development on macOS)
- **Running RexOne Core API** (`http://localhost:3000` or `http://10.0.2.2:3000` on Android emulator)

### 3-Step Setup

```bash
# 1. Clone repository
git clone git@github.com:rex-9/rexone-mobile.git
cd rexone-mobile

# 2. Install dependencies & configure pre-commit hooks
flutter pub get
./scripts/install_pre_commit.sh

# 3. Launch application (Development)
flutter run --dart-define=APP_ENV=.env.dev
```

To run in Staging (UAT) or Production mode:
```bash
# Staging / UAT
flutter run --dart-define=APP_ENV=.env.uat

# Production
flutter run --dart-define=APP_ENV=.env.prod
```

---

## 🧪 Quality & Automated Testing

RexOne Mobile enforces high engineering discipline with strict analyzer checks and multi-level automated testing:

```bash
# 1. Run static analysis across application, tests, and integration specs
flutter analyze lib/ test/ integration_test/

# 2. Run unit, controller, and widget tests (88 tests)
flutter test test/
# or: ./scripts/test_unit.sh

# 3. Validate locale parity and audit unused translation keys
./scripts/check_locales.sh
./scripts/check_locales.sh --unused

# 4. Run real on-device Flutter Driver E2E integration tests
./scripts/test_e2e.sh all -d emulator-5554
# Or specific flows: ./scripts/test_e2e.sh sign-in -d emulator-5554
```

For full testing configurations and Flutter Driver instructions, see **[`docs/README.md`](docs/README.md)**.

---

## 📚 Technical Documentation & Subsystem Architecture

To maintain high architectural discipline without cluttering the primary showcase, exhaustive technical specifications, database schemas, and CLI manuals are organized in **[`docs/`](docs/)**:

| Resource | Scope & Canonical Specification |
| :--- | :--- |
| **📖 Master Mobile Documentation Hub** | Native architecture topology, CLI script catalog, and testing guides: **[`docs/README.md`](docs/README.md)** |
| **🗄️ Client SQLite Database (Drift)** | Drift SQLite architecture, schema mirroring, offline states, and DAOs: **[`docs/CLIENT_DATABASE.md`](docs/CLIENT_DATABASE.md)** |
| **🏛️ Unified Ecosystem Architecture** | Cross-platform contracts, WebSocket event catalogs, and shared schemas: **[`ECOSYSTEM.md`](ECOSYSTEM.md)** |
| **📜 Constitutional Law** | Non-negotiable architecture, state management, and design tokens: **[`LAW.md`](LAW.md)** |
| **🤖 Autonomous Agent Governance** | Operational agent rules, secret isolation, and documentation synchronization: **[`AGENTS.md`](https://github.com/rex-9/rexone-core/blob/dev/AGENTS.md)** |

---

## 🚀 Production Releases & Automated CI/CD

RexOne Mobile includes an automated Android release pipeline in [`.github/workflows/build_android.yaml`](.github/workflows/build_android.yaml) triggering on pushes to `uat` (Pre-Release APK) and `main` (Production Release APK).

### Manual Local Builds

```bash
# Build Android Release APK
flutter build apk --release --dart-define=APP_ENV=.env.prod

# Build Android App Bundle (Google Play AAB)
flutter build appbundle --release --dart-define=APP_ENV=.env.prod

# Build iOS Release
flutter build ios --release --dart-define=APP_ENV=.env.prod
```

For required GitHub Secrets configuration, see **[`docs/README.md`](docs/README.md)**.

---

## Other Repos in RexOne Ecosystem

- [RexOne Core](https://github.com/rex-9/rexone-core) — Rails API, IAM, payments, jobs, notifications, storage, AI, administration, and observability
- [RexOne Web](https://github.com/rex-9/rexone-web) — React 19 SPA, Tailwind CSS v4, DaisyUI 5, admin consoles, and Vidstack player

---

## 🎨 Rebranding & Utility Scripts

For full, synchronized rebranding across Core, Web, and Mobile, execute the master rebrand engine from **`rexone-core`**:

```bash
cd ../rexone-core && ./scripts/rebrand.sh
```

For standalone mobile rebranding:
```bash
./scripts/rebrand.sh "New App Name" "com.company.newapp" "path/to/icon.png"
```

For the complete catalog of individual utility scripts (name, package ID, icons, versions), see **[`docs/README.md`](docs/README.md)**.

---

## 🏛️ Ecosystem Lineage & Attribution

This application is built on top of the **RexOne Ecosystem** (`rex-9`). When creating derivative products or white-label applications:

- Developers and creators are warmly encouraged to preserve ecosystem credit in documentation to support the project.
- All development must strictly adhere to the constitutional engineering standards in **[LAW.md](LAW.md)** and **[ECOSYSTEM.md](ECOSYSTEM.md)**.

---

## 💖 Sponsor & Support RexOne

RexOne is built and maintained by Rex ([@rex-9](https://github.com/rex-9)). If RexOne saves you engineering weeks, AI tokens, or cloud compute costs, consider supporting the foundation!

[![Sponsor rex-9](https://img.shields.io/badge/Sponsor-%E2%9D%A4-ea4aaa?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/rex-9)
[![GitHub Stars](https://img.shields.io/github/stars/rex-9/rexone_mobile.svg?style=social&label=Star)](https://github.com/rex-9/rexone_mobile)

👉 **[Sponsor Rex on GitHub](https://github.com/sponsors/rex-9)**

---

## Author

Architected with Discipline-Driven Development (DDD), by **Htet Naing (Rex9)**.

A full-stack architect, product craftsman, and long-time practitioner of meditation.

I build systems the same way I approach the path itself: **with a clear mind, deliberate steps, and zero unnecessary weight.**

- **Creator**: Htet Naing ([@rex-9](https://github.com/rex-9))
- **Portfolio**: [rex9.me](https://rex9.me)
- **LinkedIn**: [Htet Naing (rex9)](https://www.linkedin.com/in/rex9/)
- **X / Twitter**: [@htetnaing0814](https://x.com/htetnaing0814)

_Built with ❤️ by Htet Naing (Rex9) on the RexOne Ecosystem_

<p align="right"><a href="#readme-top">Back to top ↑</a></p>
