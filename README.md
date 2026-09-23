<a id="readme-top"></a>

<div align="center">

# RexOne Mobile

### Start from One. Not from Zero. A disciplined Flutter client, built to turn a powerful foundation into a seamless mobile product experience.

A production-minded mobile foundation for authenticated applications. Identity, payments, access control, media, AI, real-time delivery, push notifications, product analytics, in-app updates, localization, client telemetry, and reusable design primitives meet here—not as disconnected demos, but as one cohesive mobile application.

Built under the same creed as RexOne Core and RexOne Web: **Start from One. Not from Zero. Clear in thought, exact in structure, simple in use, and strong enough to endure what comes after launch.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![GetX](https://img.shields.io/badge/GetX-4.7-8A2BE2)](https://pub.dev/packages/get)
[![Sponsor rex-9](https://img.shields.io/badge/Sponsor-%E2%9D%A4-ea4aaa?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/rex-9)
[![Web Demo](https://img.shields.io/badge/Web_Demo-rexone.rex9.me-FF2238?logo=firefox&logoColor=white)](https://rexone.rex9.me)
[![CI](https://github.com/rex-9/rexone_mobile/actions/workflows/test.yml/badge.svg)](https://github.com/rex-9/rexone_mobile/actions/workflows/test.yml)

**Typed · Modular · Localized · Observable · Push-ready · Analytics-enabled · API-driven · Fully Tested**

[Live Web Demo ↗](https://rexone.rex9.me) · [Explore the client](#feature-map) · [Who it is for](#who-rexone-mobile-is-for) · [Ecosystem Architecture](ECOSYSTEM.md) · [Development Law](LAW.md) · [Run it locally](#getting-started) · [Meet the architecture](#architecture) · [Connect the API](#configuration--environment-management)

</div>

---

### 🏛️ Unified Ecosystem & Constitutional Directives

| Resource                  | Purpose & Canonical Specification                                                                                                                                                                                                                                                                                       |
| :------------------------ | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **🏛️ Unified Ecosystem**  | Complete cross-platform architecture, feature parity matrix, and communication protocols between Core, Web, and Mobile: **[Ecosystem Architecture](https://github.com/rex-9/rexone-core/blob/dev/ECOSYSTEM.md)** and **[Visual Walkthrough](https://github.com/rex-9/rexone-core/blob/dev/docs/VISUAL_WALKTHROUGH.md)** |
| **📜 Constitutional Law** | Non-negotiable architecture, design system, and state laws: **[LAW.md](LAW.md)** _(Zero exceptions)_                                                                                                                                                                                                                    |
| **🌐 AI Discovery & GEO** | Generative Engine Optimization, crawler allowlists, and LLM context files: **[AI Discovery & GEO Guide](https://github.com/rex-9/rexone-web/blob/dev/docs/SEO_GEO.md)**                                                                                                                                                 |

---

## Why RexOne Mobile?

A capable backend and a polished web app are only parts of the whole product. The mobile application must navigate device lifecycles, volatile network conditions, push notifications, app store version migrations, real-time socket events, platform sessions, biometric/passcode verification, and structured error telemetry.

RexOne Mobile exists so that work does not have to be reinvented or rebuilt from scratch for every mobile application built on RexOne Core.

### The Purpose: Start from One. Not from Zero.

Instead of burning money and compute wasting AI tokens on weak, fragmented mobile boilerplate or having to rebuild cross-platform contracts, push notifications, and state architecture again and again for every product, RexOne Mobile provides a sovereign, production-grade Flutter foundation.

**Start from One. Not from Zero.**

This is not a template of screens pretending to be an architecture. Feature modules, shared services, models, bindings, design primitives, and telemetry pipelines have exact and deliberate responsibilities:

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
| **Profile**            | Settings account row opens Profile; camera/gallery photo pick (local preview only)      | [Profile](#profile)                                                  |
| **Push Notifications** | OneSignal push messaging, permission management, user tag syncing, and click routing    | [Push notifications](#push-notifications)                            |
| **Product Analytics**  | Firebase Analytics screen tracking, auth lifecycle events, and telemetry                | [Product analytics](#product-analytics)                              |
| **In-App Upgrades**    | Splash checks `/v1/client/versions/current` and shows force or skippable update dialogs | [In-app version upgrader](#in-app-version-upgrader)                  |
| **Commerce**           | Products, Stripe Checkout WebView, subscriptions, and cancel/resume workflows           | [Payments & entitlements](#payments--entitlements)                   |
| **AI Assistant**       | Non-blocking queued chat, persistent room history, and Action Cable notifications       | [AI capabilities](#ai-capabilities)                                  |
| **Real Time**          | Action Cable WebSocket client, subscription channels, and global toast dispatching      | [Real-time delivery](#real-time-delivery)                            |
| **Observability**      | Flutter and platform error capture with automated client log delivery to RexOne Core    | [Client observability & telemetry](#client-observability--telemetry) |
| **Design System**      | Centralized design tokens, theme extensions, custom components, and light/dark modes    | [Design system](#design-system)                                      |
| **Localization**       | English and Burmese with dynamic runtime switching and `X-Locale` backend sync          | [Localization](#localization)                                        |
| **Testing (E2E)**      | Real on-device automated user journey specs via Flutter Integration Test Driver         | [End-to-End Testing](#end-to-end-testing-flutter-driver)             |
| **Quality**            | Strongly typed Dart models, analyzer compliance, and automated test suite               | [Quality & testing](#quality--testing)                               |

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

- `lib/modules/` owns product features. Each module keeps its pages, controllers, and optional feature service together, and exposes them through a barrel file (`auth.dart`, `payment.dart`, …).
- `lib/controllers/` holds only app-wide coordinators that do not belong to one feature — today, `SocketController`.
- `lib/services/` holds shared infrastructure: HTTP (`ApiService`), Action Cable, Firebase Analytics, OneSignal, storage, device permissions, and client logs.
- `lib/design/` centralizes design tokens, theme definitions, extensions, and reusable UI components.
- `lib/bindings/` handles centralized dependency injection for shared services and permanent controllers. Feature controllers that are route-scoped (Payment, Checkout, AI, Profile) are bound on their `GetPage`.
- `lib/models/` contains strongly typed JSON:API models, pagination metadata (`PaginationMeta`, `PaginatedResponse`), and response envelopes.
- `lib/locales/` contains multi-language translations and runtime dictionary updates.
- `lib/config/` and `lib/constants/` manage environment definitions, typed JSON keys (`JsonKeys`), log constants (`LogConstants`), and application constants.
- `integration_test/` houses end-to-end integration specifications, test robots, and test data factories.
- `test_driver/` houses the Flutter driver entrypoint bridging device execution with test reporting.

---

## The client in detail

### Authentication & security

- **Smart Email Discovery**: Automatically checks user registration and confirmation state via `GET /peek`.
- **6-Digit Password**: In-memory password handling for sign-in and registration (credentials never leak to persistent storage or route arguments).
- **Unconfirmed Drop-off Recovery**: Returning unconfirmed users route directly to email confirmation OTP, bypassing credentials setup.
- **Escalating Attempt Protection**: Reactive password retry limits and cooldown counters driven dynamically by rexone-core.
- **Email Confirmation**: 6-digit email OTP verification with countdown-guarded resend capabilities.
- **Google Sign-In**: Native Google OAuth flow with RexOne Core challenge token support for first-time signups.
- **Active Session Enforcement**: Sends `X-Platform: android` or `X-Platform: ios` so Core maintains an isolated active session for each native platform.
- **Session Replacement Handling**: Detects active session invalidation and gracefully routes the user to sign-in with localized feedback.

### Profile

- Own feature module at `lib/modules/profile/` (route-scoped `ProfileController` on `/profile`).
- Opened from the Settings account row (`AppRoutes.toProfile`).
- Prefills full name, username, and email from the signed-in `UserModel`. Email is read-only.
- Edit badge on the avatar opens a camera or gallery sheet (`image_picker`). Save PUTs name/username on `/v1/users/current` and uploads a picked avatar.
- Camera and photo-library prompts go through shared `PermissionService` (same Settings dialog pattern as the AI microphone).

### IAM & RBAC Administrative Hierarchy

The mobile client enforces a synchronized three-tier administrative hierarchy:

- **`super_admin`**: Full authority across all features, screens, and administrative tools.
- **`admin`**: Full authority across domain operations (`feedbacks`, `payments`, `ai`, `assets`, `logs`), strictly excluded from `users` and `iam`.
- **Partial Admins (`*_admin` naming convention)**: Users holding the base `user` role plus a specific `*_admin` role (e.g. `feedback_admin`). Any role with `admin` in its name is an admin role. Permissions in admin roles grant access to both standard and admin endpoints, whereas permissions in non-admin roles (such as `user`) only grant access to non-admin features.

### Push notifications

- Powered by **OneSignal Flutter SDK** (`onesignal_flutter`).
- Native push notifications for Android and iOS (`remote-notification` background modes).
- User identification and tag synchronization (`syncUser(user)` and `clearUser()`) hooked directly into authentication state changes.
- Click listeners that route notifications and track conversion events via `AnalyticsService`.

### Product analytics

- Powered by **Firebase Analytics** (`firebase_core` & `firebase_analytics`).
- Central navigation tracking emits the shared `view_page` event from `GetMaterialApp.navigatorObservers`.
- Constantized `action_noun` events cover `sign_up`, `sign_in`, `sign_out`, `begin_onboarding`, `complete_onboarding`, `view_page`, `view_product`, `purchase_product`, and `open_notification`.
- Every event includes `platform: android` or `platform: ios` so the shared GA4 property can filter Web and Mobile consistently.
- User ID tagging synchronized with authenticated sessions.
- Email addresses and other personal data are never sent to Firebase Analytics.

### In-app version upgrader

- Checked during app startup via `VersionService` (`GET /v1/client/versions/current?version=...&build_number=...`) using canonical `AppInfo` metadata.
- `must_update`: Handled exclusively by the sovereign full-screen `SplashPage` blocking view with `PopScope(canPop: false)` and direct store handoff. If detected on app resume in `HomeController`, the app routes directly back to `SplashPage`.
- `update_required` (optional): Prompted non-blockingly on `HomePage` via `AppDialog.update` with "Later" and "Update" options.
- System store handoff opens API `store_url` via `url_launcher`.

### Payments & entitlements

- Product catalogue with one-time and recurring pricing and pagination support.
- Promo & referral coupon validation (`POST /v1/payment/coupons/validate`) directly in `CheckoutBottomSheet` with real-time discount calculation and localized pricing.
- In-app Stripe Checkout handoff via WebView (`webview_flutter`) with attached coupon codes.
- 100% discount free access bypass: zero-amount checkouts bypass Stripe, provision immediate product access via Core `AccessService`, and close the bottom sheet with instant entitlement feedback.
- Subscription state management (Active, Scheduled for Cancellation, Expired).
- Safe end-of-period cancellation and resumption guarded by destructive confirmation dialogs.

### AI capabilities

- Non-blocking conversational AI assistant backed by RexOne Core and DeepSeek.
- Multi-room management with persistent chat history and pagination support.
- Real-time response completion notifications delivered via Action Cable.
- Room deletion and chat clearing guarded by destructive confirmation prompts.

### Real-time delivery

- Real-time WebSocket connection to RexOne Core via Action Cable (`SolidCable`).
- Auto-reconnect and token refresh on authentication.
- Centralized `SocketController` dispatches notifications and manages global toast feedback.

### Media playback

- Unified feature module at `lib/modules/media/` with a shared `MediaPlaylistPage` + `MediaPlaylistController`, separate audio and video player stacks, and routes declared in `AppRoutes` only (no module-level `*.routes.dart`).
- **Playlist**: Mixed library from `GET /v1/assets` (no type filter) showing audio, video, avatar/image, and attachment rows (subtitle/thumbnail sidecars excluded). Tap plays A/V, previews images, or opens attachments externally. Header **Play All** starts the first playable item; **Download all** bulk-enqueues offline saves. Home exposes one **Playlist** button → `AppRoutes.toPlaylist()` (`/media-playlist`).
- **Playback URLs**: At play time, `GET /v1/assets/:id/playback` returns a signed `delivery.url` and fresh `media.subtitles[]` for audio/video. `MediaService.getAssetPlayback()` caches responses until near `expires_at`; players do not fall back to list `asset.url`. Image/attachment downloads use the list/signed `asset.url`.
- **Mixed queue**: Next/previous follow the playlist via `AudioPlayerService.playQueueAt()`, skipping non-playable rows — audio continues in the mini/full player; video opens the inline player and hands back to audio when the next item is audio.
- **Audio**: Background playback via `just_audio` + `just_audio_background`, persistent mini player, lock-screen Now Playing on iOS, and Apple Music–style synced lyrics from playback- or list-resolved `children.subtitles[]` (SRT), with a track picker when multiple subtitle files exist.
- **Video**: Inline 16:9 player via `better_player`, with built-in playback-speed controls, closed captions from the same subtitle tracks (prefetched SRT URLs into better_player’s subtitle menu), 100MB chunk disk caching via `CacheConfiguration`, low-latency buffer tuning (15s min / 60s max / 2s initial playback) via `BufferingConfiguration`, dedicated audio focus management (`setMixWithOthers(false)`) preventing AudioTrack dropouts, automatic seek position heartbeat recovery, and gap-bridged subtitle preloading (`SrtHelper.bridgeSmallGaps`).
- **Offline downloads & Drift SQLite**: Per-item download from the playlist stores media and sidecars in the app sandbox (`ApplicationSupport/media_offline/`). Fully backed by a local **Drift (SQLite)** database (`rexone_offline`, documented in [`docs/CLIENT_DATABASE.md`](docs/CLIENT_DATABASE.md)) strictly mirroring the backend polymorphic `assets` schema.
  - **Offline Playlist Mode**: When offline, the playlist queries local Drift SQLite; if no downloads exist, a straightforward empty state is shown ("No downloaded videos to view in offline mode. Connect to the internet to stream or download videos to enjoy offline."). If 1 or 2 items are downloaded, only those items appear and play smoothly with offline thumbnails and subtitles. Reconnecting auto-refreshes the full catalog.
  - **Local-First Playback**: If an asset is already downloaded, it always plays from local decrypted storage even when the device is online, saving user bandwidth and providing instant playback.
  - **Single Icon-Space UX**: Trailing controls occupy strictly one icon-space across all states (no jumping layouts): `none` (download icon), `queued`/`downloading` (progress ring enclosing pause icon), `paused` (progress ring enclosing resume icon), `ready` (single `'x'` close icon to remove), `failed` (retry icon). Active playback state is indicated by an artwork overlay and colored title.
  - **Storage Transparency**: File sizes and progress are displayed across states: before download (`00:15 · 4.2 MB`), downloading (`Downloading 1.2 MB / 4.2 MB (28%)`), ready (`00:15 · 4.2 MB · Downloaded`). Tapping `'x'` presents a confirmation dialog indicating exact freed storage (`Remove (4.2 MB)`).
  - **Security & Background Transfer**: AES-256-GCM sandbox encryption, max 2 concurrent transfers, and background execution via `background_downloader` with Android foreground notifications and iOS Live Activity support (`MediaDownloadWidget`).
- **Shared helpers**: `SrtHelper` (parse + active cue + gap bridging + timestamp formatting), `VideoLayoutHelper` (inline viewport sizing), `FileSizeHelper` (byte and progress formatting), `MediaLayoutConstants`, `MediaPlaybackConstants`, and `MediaEncryptionHelper`.
- Services return `Future<bool>` for playback failures; controllers and pages surface errors via `AppSnackbar` (LAW §3.3 — services never show UI).

> [!IMPORTANT]
> Offline encryption is practical sandbox protection, not DRM. The env key is bundled with the app; a determined attacker on a rooted/jailbroken device can still extract offline media.

### Client observability & telemetry

- Global error capture through `FlutterError.onError` and `PlatformDispatcher.instance.onError`.
- Structured diagnostic payloads (message, stack trace, device metadata, OS version, app version, local storage keys) delivered directly to RexOne Core's `POST /v1/client/logs`.
- Environment names validated against canonical backend schemas (`development`, `staging`, `production`).

### Design system

- Centralized design entry point via `import 'package:rexone_mobile/design/design.dart';`.
- Complete design tokens: `Design.spacing`, `Design.typography`, `Design.icons`, and `Design.timers`.
- Theme extensions for theme-aware colors and typography (`context.colors`, `context.typo`).
- Reusable components: `AppButton`, `AppInputField`, `AppPasswordField`, `AppDialog`, `AppLoading`, `AppPage`, and `AppSnackbar`.
- Cohesive light and dark themes with persistent user preferences.

### Localization

- Fully localized into:
  - 🇬🇧 **English (`en_US`)**
  - 🇲🇲 **Burmese (`my_MM`)**
- Complete parity across all user-facing texts with dynamic runtime GetX translation reload.
- Automatically sends `X-Locale` and `Accept-Language` headers on all HTTP requests to ensure backend responses match the user's selected language.

---

## Speech & AI Assistant

RexOne Mobile pairs reactive GetX UI with real-time audio and AI capabilities:

- **Live Voice Dictation (STT)**:
  - Microphones stream normalized 16-bit PCM chunks to Core's ActionCable `SpeechLiveChannel` in real time.
  - Interactive `VoiceLevelBars` wave animation visualizes live amplitude and voice input levels.
  - Seamless fallback with automatic cancellation and error handling.
- **Text-to-Speech (TTS) Playback**:
  - Direct binary audio stream playback via `just_audio` / `AudioPlayer` without base64 overhead.
  - Message-level speech synthesis button with animated loading states and playing indicators.
  - Background completion notifications (`tts_ready`) dynamically link generated MP3 assets to assistant message bubbles.
- **Conversational AI Chat**:
  - Non-blocking queued AI chat execution with persistent conversation rooms and message history.
  - Optimistic UI updates with live thinking indicators and ActionCable socket synchronization.

---

## End-to-End Testing (Flutter Driver)

RexOne Mobile includes on-device E2E tests built with **`package:integration_test`** and Flutter Driver. Tests exercise real user flows on active iOS Simulators or Android Emulators without mocking UI behavior.

### Test Structure

```text
rexone_mobile/
├── integration_test/
│   ├── auth/
│   │   ├── password_test.dart       # Password acceptance, rejection, and retries
│   │   ├── password_reset_test.dart # Forgot password request flow
│   │   ├── sign_in_test.dart        # End-to-end sign-in, drop-off recovery & home navigation
│   │   ├── sign_out_test.dart       # Sign out & session termination
│   │   ├── sign_up_test.dart        # Full registration & email confirmation
│   │   └── sso_test.dart            # Google SSO button presence & interaction
│   ├── data/
│   │   └── users.dart               # Test user definitions & dynamic factory
│   └── robots/                      # Test Robot helper classes
├── test_driver/
│   └── integration_test.dart        # Flutter Driver bridge entrypoint
└── scripts/
    ├── test.sh                   # Full test suite runner (Unit + E2E)
    ├── test_unit.sh              # Flutter unit test runner
    └── test_e2e.sh               # Mobile E2E runner CLI
```

### Running Tests

RexOne Mobile provides specialized and unified test runner scripts in [`scripts/`](scripts/):

```bash
# 1. Run FULL test suite (Unit + E2E)
./scripts/test.sh all -d emulator-5554

# 2. Run ONLY Unit tests (Flutter Test) - fast feedback loop
./scripts/test_unit.sh
# or: flutter test

# 3. Run ONLY E2E tests (Flutter Drive / Integration Test)
./scripts/test_e2e.sh all -d emulator-5554

# Run specific E2E flows
./scripts/test_e2e.sh sign-in -d emulator-5554
./scripts/test_e2e.sh sign-up -d emulator-5554
./scripts/test_e2e.sh password -d emulator-5554
./scripts/test_e2e.sh password-reset -d emulator-5554
./scripts/test_e2e.sh sign-out -d emulator-5554
./scripts/test_e2e.sh sso -d emulator-5554

# Or run on iOS Simulator
./scripts/test_e2e.sh sign-in -d "iPhone 16 Pro"
```

Or run via Flutter Driver directly:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/auth/sign_in_test.dart \
  -d emulator-5554
```

---

## Getting started

### Prerequisites

- **Flutter SDK**: `>= 3.11.5`
- **Dart SDK**: `>= 3.11.5`
- **Android Studio** / **VS Code** with Flutter extensions
- **Xcode** (for iOS development on macOS)
- **CocoaPods** (for iOS dependency management)

Verify your environment:

```sh
flutter doctor
```

### Installation

1. Clone the repository:

```sh
git clone git@github.com:rex-9/rexone-mobile.git
cd rexone-mobile
```

2. Install dependencies & pre-commit hooks:

```sh
flutter pub get
./scripts/install_pre_commit.sh
```

Run the same centralized checks used by GitHub Actions:

```sh
./scripts/ci.sh
```

3. Configure environment variables:
   Create `.env.dev`, `.env.uat`, or `.env.prod` in the project root:

```env
APP_NAME=RexOne
APP_VERSION=1.0.0
API_BASE_URL=http://10.0.2.2:3000
GOOGLE_SERVER_CLIENT_ID=your_google_server_client_id.apps.googleusercontent.com
ONE_SIGNAL_APP_ID=your_onesignal_app_id
ANDROID_APP_ID=com.rex9.rexone
IOS_APP_ID=com.rex9.rexone
```

4. Configure Firebase & Google Services:

- **Android**: Copy `android/app/google-services.json.example` to `android/app/google-services.json` and configure your Firebase project values.
- **iOS**: Copy `ios/Runner/GoogleService-Info.plist.example` to `ios/Runner/GoogleService-Info.plist` and configure your Firebase project values.

**Note:** `google-services.json` and `GoogleService-Info.plist` are included in `.gitignore` to prevent credential exposure.

---

## Running the application

### Development:

```sh
flutter run --dart-define=APP_ENV=.env.dev
```

### Staging (UAT):

```sh
flutter run --dart-define=APP_ENV=.env.uat
```

### Production:

```sh
flutter run --dart-define=APP_ENV=.env.prod
```

---

## Quality & testing

Run static analysis:

```sh
flutter analyze lib/ test/ integration_test/
```

Validate locale parity, interpolation placeholders, and `AppLocales` usage:

```sh
./scripts/check_locales.sh

# Audit unreferenced/unused translation keys:
./scripts/check_locales.sh --unused
```

Run unit and widget tests:

```sh
flutter test test/
```

GitHub Actions restores Flutter and Pub packages from cache before running the same centralized `scripts/ci.sh` checks.

Run on-device integration tests:

```sh
./scripts/test.sh all -d emulator-5554
```

---

## Building for production

### Automated CI/CD (GitHub Actions)

RexOne Mobile includes an automated Android build and release pipeline ([`.github/workflows/build_android.yaml`](.github/workflows/build_android.yaml)):

- **UAT Builds (Pushed or Merged to `uat` branch)**:
  - Automatically injects the `ENV_UAT` GitHub Secret into `.env.uat`.
  - Builds the release APK with `--dart-define=APP_ENV=.env.uat`.
  - Uploads `rexone-uat-v${VERSION}-b${BUILD}.apk` as a workflow artifact.
  - Automatically creates a GitHub Pre-Release tagged `v${VERSION}-uat+${BUILD}` with the APK attached.
- **Production Builds (Pushed or Merged to `main` branch)**:
  - Automatically injects the `ENV_PROD` GitHub Secret into `.env.prod`.
  - Builds the release APK with `--dart-define=APP_ENV=.env.prod`.
  - Uploads `rexone-prod-v${VERSION}-b${BUILD}.apk` as a workflow artifact.
  - Automatically creates a production GitHub Release tagged `v${VERSION}+${BUILD}` with the APK attached.
  - _Integration Tip_: The GitHub Release download link can be linked directly into the RexOne Admin App Versions portal (`/v1/admin/client/versions`) to distribute in-app updates!

#### Required GitHub Repository Secrets:

Configure in repository **Settings > Secrets and variables > Actions**:

| Secret Name                   | Scope             | Branch         | Description                                                                                                                             |
| :---------------------------- | :---------------- | :------------- | :-------------------------------------------------------------------------------------------------------------------------------------- |
| `ENV_UAT`                     | Required for UAT  | `uat`          | The raw file content of `.env.uat`. Injected into `.env.uat` prior to build.                                                            |
| `ENV_PROD`                    | Required for Prod | `main`         | The raw file content of `.env.prod`. Injected into `.env.prod` prior to build.                                                          |
| `GOOGLE_SERVICES_JSON`        | Recommended       | `uat` & `main` | Raw JSON content of `android/app/google-services.json`. Shared across UAT and Production builds.                                        |
| `GOOGLE_SERVICES_JSON_UAT`    | Optional          | `uat`          | Environment-specific `google-services.json` if using a separate UAT Firebase project. Overrides `GOOGLE_SERVICES_JSON` for UAT.         |
| `GOOGLE_SERVICES_JSON_PROD`   | Optional          | `main`         | Environment-specific `google-services.json` if using a separate Production Firebase project. Overrides `GOOGLE_SERVICES_JSON` for Prod. |
| `GOOGLE_SERVICES_JSON_BASE64` | Optional          | `uat` & `main` | Base64-encoded string of `android/app/google-services.json` (`base64 -i android/app/google-services.json`).                             |
| `GOOGLE_SERVICE_INFO_PLIST`   | Recommended (iOS) | `uat` & `main` | Raw XML content of `ios/Runner/GoogleService-Info.plist` for iOS CI builds.                                                             |

### 🛡️ CI Fallback Safeguard

If `GOOGLE_SERVICES_JSON*` is not yet configured in GitHub Secrets, the pipeline automatically falls back to [`android/app/google-services.json.example`](android/app/google-services.json.example) so the Gradle `:app:processReleaseGoogleServices` build step compiles cleanly without breaking the workflow. Live Firebase services (Analytics, Push Notifications) require the real secret.

### 💡 Exporting for GitHub Secrets

- **Direct JSON**: Open `android/app/google-services.json`, copy the JSON contents, and paste into `GOOGLE_SERVICES_JSON` (or `GOOGLE_SERVICES_JSON_UAT` / `GOOGLE_SERVICES_JSON_PROD`).
- **Base64 format** (avoids whitespace or line break formatting issues):
  ```sh
  base64 -i android/app/google-services.json | pbcopy
  # Paste directly into GOOGLE_SERVICES_JSON_BASE64
  ```

---

### Manual Local Builds

#### Android APK:

```sh
# UAT:
flutter build apk --release --dart-define=APP_ENV=.env.uat

# Production:
flutter build apk --release --dart-define=APP_ENV=.env.prod
```

#### Android App Bundle (AAB for Google Play):

```sh
flutter build appbundle --release --dart-define=APP_ENV=.env.prod
```

#### iOS Release:

```sh
flutter build ios --release --dart-define=APP_ENV=.env.prod
```

---

## Project structure

```text
rexone_mobile/
├── android/                  # Android native project & Gradle config
├── ios/                      # iOS native project & CocoaPods config
├── integration_test/         # On-device integration tests & test robots
├── lib/
│   ├── bindings/             # GetX DI for shared services and permanent controllers
│   ├── config/               # App configuration and environment resolution
│   ├── constants/            # Constants, analytics event keys, locale keys, HTTP status
│   ├── controllers/          # App-wide coordinators only (SocketController)
│   ├── design/               # Design system (tokens, components, extensions, themes, icons)
│   │   ├── components/       # Reusable atoms and molecules (Button, Input, Password, Dialog, Loading)
│   │   ├── elements/         # Design tokens (Colors, Spacing, Typography, Icons, Timers)
│   │   └── extensions/       # Theme context extensions
│   ├── helpers/              # Utility helpers (API JSON:API parser, flags, validators)
│   ├── locales/              # Multi-language translations (en_US, my_MM)
│   ├── models/               # Strongly typed models and JSON:API response envelopes
│   ├── modules/              # Feature modules (pages + controllers + feature services)
│   │   ├── splash/           # Launch / session restore
│   │   ├── auth/             # Welcome, password, signup, OTP, recovery
│   │   ├── home/             # Main dashboard
│   │   ├── payment/          # Plans, Stripe Checkout WebView, subscriptions
│   │   ├── profile/          # Account profile, avatar upload
│   │   ├── setting/          # Theme, language, and account row
│   │   ├── ai/               # Assistant chat, rooms, history
│   │   └── media/            # Mixed media library (shared + audio/ + video/)
│   │       ├── components/   # TrackArtwork, playlist tile/header/empty/load-more
│   │       ├── controllers/  # MediaPlaylistController (library + bulk download)
│   │       ├── pages/        # MediaPlaylistPage
│   │       ├── audio/        # Full player, mini player, synced lyrics
│   │       └── video/        # Inline better_player + viewport
│   ├── routes/               # GetX route declarations and auth route guards
│   └── services/             # Shared transport (API, Socket, Log, Analytics, Push, Storage, Permissions)
├── scripts/
│   ├── check_secrets.sh       # Pre-commit secret scanner (blocks uncommitted .env files and live API keys)
│   ├── install_pre_commit.sh  # Master pre-commit hook installer (secrets + locales)
│   ├── check_locales.sh       # Validate translations & audit unused keys
│   ├── rebrand.sh             # Unified mobile rebranding (Name + Package + Icon)
│   ├── update_app_name.sh     # App display name updater (Android, iOS, .env)
│   ├── update_package_name.sh # Package identifier / Bundle ID updater
│   ├── update_app_icon.sh     # Launcher icons generator
│   ├── update_app_version.sh  # Version and build number incrementer
│   ├── test.sh                # Full test suite runner (Unit + E2E)
│   ├── test_unit.sh           # Flutter unit test runner
│   └── test_e2e.sh            # E2E integration test CLI runner (auto DB lifecycle & device detection)
├── test/                      # Unit, controller, and localization tests (88 tests)
│   ├── controllers/           # Socket controller tests
│   ├── mocks/                 # In-memory test service doubles
│   ├── modules/               # Auth, Notification, Feedback, Setting, Payment, AI, Media tests
│   └── services/              # Speech and core service tests
├── test_driver/
│   └── integration_test.dart  # Flutter Driver test bridge
└── pubspec.yaml
```

---

## 🎨 Rebranding & Utility Scripts

### 💡 Master Rebranding Engine

For full, synchronized rebranding across all 3 platforms (Core Backend, Web SPA, and Mobile App), run the master rebrand engine from **`rexone-core`**:

```bash
cd ../rexone-core && ./scripts/rebrand.sh
```

For standalone mobile development or isolated updates, you can use the local scripts below:

```bash
# 1. Standalone Mobile Rebrand (Name + Package ID + App Icon)
./scripts/rebrand.sh "New App Name" "com.company.newapp" "path/to/icon.png"

# 2. Update App Display Name only
./scripts/update_app_name.sh "New App Name"

# 3. Update Package Name / Bundle ID only
./scripts/update_package_name.sh com.company.newapp

# 4. Generate Launcher Icons from assets/brand/logo.png
./scripts/update_app_icon.sh

# 5. Bump Version and Build Number
./scripts/update_app_version.sh 1.1.0

# 6. Validate Translations and Check Unreferenced Keys
./scripts/check_locales.sh [--unused]

# 7. Run On-Device E2E Tests (with automated device detection & DB lifecycle)
./scripts/test_e2e.sh [-d <device-id>]
```

---

## 🏛️ Ecosystem Lineage & Attribution

This application is built on top of the **RexOne Ecosystem** (`rex-9`). When creating derivative products or white-label applications:

- Developers and creators are warmly encouraged to preserve ecosystem credit in documentation to support the project.
- All development must strictly adhere to the constitutional engineering standards in **[LAW.md](LAW.md)** and **[ECOSYSTEM.md](ECOSYSTEM.md)**.

---

## Author

Built with Clarity & Simplicity Driven Development, by **Rex (Rex9)**.

A software engineer, full-stack architect, and long-time practitioner of meditation.

I build systems the same way I approach the path itself: **with a clear mind, deliberate steps, and no unnecessary weight.**

- GitHub: [@rex-9](https://github.com/rex-9)
- Portfolio: [rex9.me](https://rex9.me)
- LinkedIn: [rex9](https://www.linkedin.com/in/rex9/)

_Built with ❤️ by Rex9 on RexOne Ecosystem_

<p align="right"><a href="#readme-top">Back to top ↑</a></p>
