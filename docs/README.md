# RexOne Mobile: Technical Documentation & Native Subsystem Reference

This directory serves as the technical documentation manual for **RexOne Mobile** (`rexone_mobile`), the sovereign Flutter 3 native iOS and Android client for the RexOne ecosystem.

---

## 📚 Documentation Index

| Guide | Description | Canonical Path |
| :--- | :--- | :--- |
| **🚀 Store Deployment & CI/CD** | Step-by-step store publishing, GitHub Actions automation, and TestFlight pipeline | **[`docs/DEPLOYMENT.md`](DEPLOYMENT.md)** |
| **🗄️ Client SQLite Database (Drift)** | Drift SQLite architecture, schema mirroring, offline states, and local caching | **[`docs/CLIENT_DATABASE.md`](CLIENT_DATABASE.md)** |
| **🏛️ Unified Ecosystem Architecture** | Cross-platform contracts, WebSocket event catalogs, and shared data structures | **[`ECOSYSTEM.md`](../ECOSYSTEM.md)** |
| **📜 Constitutional Law** | Non-negotiable architecture, state management, and design system rules | **[`LAW.md`](../LAW.md)** |
| **🤖 Autonomous Agent Governance** | Operational agent rules, secret isolation, and documentation synchronization | **[`AGENTS.md`](https://github.com/rex-9/rexone-core/blob/dev/AGENTS.md)** |
| **🌐 AI Discovery & GEO** | Generative Engine Optimization, crawler allowlists, and LLM context files | **[`docs/SEO_GEO.md`](https://github.com/rex-9/rexone-web/blob/dev/docs/SEO_GEO.md)** |

---

## 🏛️ Native Architecture & Directory Topology

RexOne Mobile enforces strict Clean Architecture separation across distinct functional layers:

```text
lib/
├── bindings/             # Centralized GetX DI for shared services and permanent controllers
├── config/               # App configuration and environment resolution (.env.dev, .env.uat, .env.prod)
├── constants/            # Standardized constants (*.constants.dart), analytics keys, locale keys, HTTP status
├── controllers/          # App-wide coordinators (SocketController) and mixins (PagyControllerMixin)
├── data/
│   └── local/            # Drift SQLite database (rexone_offline), tables, DAOs, and migrations
├── design/               # Design system tokens, reusable UI primitives, and themes
│   ├── components/       # AppAccessGate, AppButton, AppInputField, AppPasswordField, AppDialog, AppLoading, etc.
│   ├── elements/         # Design tokens (Colors, Spacing, Typography, Icons, Timers)
│   └── extensions/       # Theme context extensions (context.colors, context.typo)
├── helpers/              # Utility helpers (JSON:API parser, validators, media encryption)
├── locales/              # Multi-language translations (English en_US, Burmese my_MM)
├── models/               # Core strongly typed models and response envelopes
├── modules/              # Cohesive feature modules with flat, symmetric architecture:
│   │                     # ├── components/ (optional widgets)
│   │                     # ├── controllers/ (GetX controllers)
│   │                     # ├── models/ (domain models, zero redundant data/ layer)
│   │                     # ├── pages/ (full screen views)
│   │                     # ├── requests/ (API request DTOs)
│   │                     # ├── services/ (feature API clients)
│   │                     # └── <feature>.dart (single barrel export)
│   ├── ai/               # Non-blocking queued AI chat, multi-room management, live thinking
│   ├── auth/             # Welcome, smart email discovery, 6-digit password, OTP, recovery
│   ├── feedback/         # In-app user feedback and rating collection
│   ├── home/             # Main dashboard, quick actions, and upgrade prompts
│   ├── media/            # Mixed media library, dual players, offline downloads
│   ├── notification/     # In-app and push notification inbox, mark-as-read, real-time toasts
│   ├── payment/          # Product catalogue, coupon validation, Stripe Checkout WebView
│   ├── profile/          # Account profile management, avatar camera/gallery upload
│   ├── setting/          # Theme toggle, language switcher, and account navigation
│   └── splash/           # Launch, session restoration, blocking version upgrade
├── routes/               # GetX route declarations and auth route guards
└── services/             # Shared transport gateways (ApiService, SocketService, AnalyticsService, PushNotificationService, LogService)
```

### Layer Boundaries:
- **Presentation (`lib/modules/*/pages/`, `lib/design/`)**: Pure UI widgets. Widgets never instantiate transport clients, mutate storage directly, or execute business logic.
- **Business Logic (`lib/modules/*/controllers/`)**: Reactive GetX controllers managing feature state, user gestures, and coordinating with services.
- **Data & Transport (`lib/services/`, `lib/models/`, `lib/modules/*/models/`, `lib/modules/*/requests/`)**: Strongly typed models, JSON:API response envelopes, request DTOs, and single-responsibility transport clients.
- **Local Persistence (`lib/data/local/`)**: Type-safe Drift SQLite database (`rexone_offline`) mirroring backend tables for resilient local-first operation.

---

## 🛠️ CLI Development & Utility Toolchain

All local development, code verification, translation checks, and rebranding tasks are automated via deterministic shell scripts located in `scripts/`:

| Script | Purpose | Options / Flags |
| :--- | :--- | :--- |
| `./scripts/test.sh` | Runs full automated test suite (Unit tests + on-device E2E) | `all -d <device-id>` |
| `./scripts/test_unit.sh` | Runs fast Flutter unit, controller, and widget tests | None (or `flutter test`) |
| `./scripts/test_e2e.sh` | Executes real on-device Flutter Driver integration tests | `[flow] -d <device-id>` |
| `./scripts/ci.sh` | Centralized CI script running static analysis, tests, and checks | None |
| `./scripts/check_locales.sh` | Validates English/Burmese translation parity & placeholder matches | `--unused` (audit unreferenced keys) |
| `./scripts/check_secrets.sh` | Pre-commit scanner blocking live credentials and untracked `.env` files | `--install`, `--all` |
| `./scripts/install_pre_commit.sh` | Installs pre-commit Git hooks for secrets and translation validation | None |
| `./scripts/generate_keystore.sh` | Generates standard Android release keystore & exports Base64 secret | `[app_name] [alias]` |
| `./scripts/copy_keystore_base64.sh` | Encodes existing upload keystore to Base64 and copies to clipboard | `[app_name]` |
| `./scripts/copy_play_store_key.sh` | Copies Google Play Service Account JSON key to clipboard | `[app_name]` |
| `./scripts/release_android.sh` | Compiles release Android App Bundle (.aab) or APK locally | `[prod\|uat] [--bundle\|--apk\|--all] [--build-number <num>]` |
| `./scripts/release_ios.sh` | Builds release IPA locally and deploys to Apple TestFlight | `[prod\|uat] [--build-only] [--validate-only] [--build-number <num>]` |
| `./scripts/rebrand.sh` | Standalone mobile rebranding (App Display Name + Package ID + App Icon) | `"<Name>" "<bundle.id>" "<icon.png>"` |
| `./scripts/update_app_name.sh` | Updates app display name across Android, iOS, and environment files | `"<New App Name>"` |
| `./scripts/update_package_name.sh` | Updates package identifier and iOS Bundle ID across native projects | `<com.company.app>` |
| `./scripts/update_app_icon.sh` | Generates native launcher icons from `assets/brand/logo.png` | None |
| `./scripts/update_app_version.sh` | Increments version name and build number in `pubspec.yaml` | `<version>` |

---

## 🔐 Security, Storage & Environment Management

### Multi-Environment Configuration
RexOne Mobile resolves configuration at compile time using `--dart-define=APP_ENV=...`:
- **Development**: `flutter run --dart-define=APP_ENV=.env.dev` (default API: `http://10.0.2.2:3000` on Android emulator, `http://localhost:3000` on iOS Simulator)
- **Staging / UAT**: `flutter run --dart-define=APP_ENV=.env.uat`
- **Production**: `flutter run --dart-define=APP_ENV=.env.prod`

> [!WARNING]
> **Dev & Prod Physical Device Overwrite Behavior**:
> Both local Development (`.env.dev`) and Production (`.env.prod`) compile under the primary base package ID (`<com.company.app>`).
> Deploying a local development build directly to a physical smartphone that already has the Production app installed will **overwrite** the Production app.
> To test pre-release features without replacing your installed Production app on physical devices, use **UAT / Staging** (`<com.company.app>.uat`), which possesses a distinct application ID and installs completely side-by-side.

### Sensitive Credentials & State Isolation
- **In-Memory Passwords**: Passwords and passcodes are held strictly in memory during authentication flows. They are never written to `SharedPreferences`, Drift SQLite, or passed via URL route arguments.
- **Platform Session Isolation**: Every API request includes `X-Platform: android` or `X-Platform: ios`. RexOne Core maintains isolated platform sessions, ensuring web and mobile sign-ins do not clobber each other.
- **Session Invalidation Handling**: When an active session is replaced or revoked, `ApiService` intercepts the 401 response and dispatches an orderly transition to `/auth` with localized user feedback.

---

## 🎬 Native Media Streaming, Offline Downloader & Speech

RexOne Mobile includes a dedicated media and offline streaming pipeline designed for low-latency playback and airplane-mode durability:

### Dual-Player Architecture
- **Video Playback (`better_player`)**:
  - Hardware-accelerated 16:9 inline viewport with dynamic letterbox calculation (`VideoLayoutHelper`).
  - Dedicated audio focus management (`setMixWithOthers(false)`) preventing AudioTrack conflicts.
  - Low-latency buffer tuning: 15s minimum, 60s maximum, 2s initial playback threshold.
  - 100MB chunk disk caching via `CacheConfiguration`.
  - Subtitle track selector supporting prefetched SRT subtitle tracks with gap bridging (`SrtHelper.bridgeSmallGaps`).
- **Audio Playback (`just_audio` + `just_audio_background`)**:
  - Background audio playback with lock-screen Now Playing controls on iOS and notification controls on Android.
  - Persistent mini player bar across application routes.
  - Apple Music-style real-time synced lyrics parsed from SRT tracks with active cue highlighting.

### Drift SQLite Offline Persistence (`rexone_offline`)
- **Schema Parity**: Local database tables (`local_assets`, `local_child_assets`) strictly mirror backend polymorphic schemas (see [`docs/CLIENT_DATABASE.md`](CLIENT_DATABASE.md)).
- **Local-First Playback**: When an asset is downloaded, playback routes to local decrypted files even when online, conserving bandwidth and delivering 0ms buffer starts.
- **Offline Playlist Mode**: In airplane mode, the playlist queries Drift SQLite. If items exist, they play immediately with offline thumbnails and SRT subtitles.
- **AES-256-GCM Encryption**: Downloaded media files are encrypted in the local application sandbox (`ApplicationSupport/media_offline/`).
- **Background Downloader**: Utilizes `background_downloader` with Android foreground services and iOS Live Activity support (`MediaDownloadWidget`), supporting download pause, resume, cancel, and disk quota verification.

### Real-Time Speech (STT & TTS)
- **Live Voice Dictation (STT)**: Streams 16kHz 16-bit mono linear PCM audio over ActionCable `SpeechLiveChannel` with interactive `VoiceLevelBars` amplitude visualization.
- **Text-to-Speech (TTS)**: Direct binary stream playback via `just_audio` with background completion notification (`tts_ready`) linking synthesized audio to chat messages.

---

## 🚀 Production Releases & Automated CI/CD

RexOne Mobile implements a sovereign **hybrid release pipeline** designed for zero cloud cost and maximum speed:
- **Android (Automated Cloud CI/CD)**: GitHub Actions ([`.github/workflows/build_android.yaml`](../.github/workflows/build_android.yaml)) compiles release APKs and App Bundles (`.aab`) on standard Linux runners (`ubuntu-latest`), automatically publishing to Google Play's **Internal Testing** track on pushes to `uat` or `main`.
- **iOS (Native Local Apple Silicon Pipeline)**: Native M-series builds via [`./scripts/release_ios.sh`](../scripts/release_ios.sh) upload directly to Apple **TestFlight** in ~90 seconds using App Store Connect API keys (`.p8`), preserving your free GitHub Actions quota (avoiding macOS 10x multiplier).

### 📖 Master Step-by-Step Deployment Guide
For complete instructions on keystore generation, Google Cloud Service Account permissions, GitHub Secrets configuration, Apple `.p8` credential setup, monotonic build number management, and troubleshooting, see the authoritative manual:

👉 **[`docs/DEPLOYMENT.md`](DEPLOYMENT.md)**

### 📱 Quick Command Reference
```bash
# Fast-fail pre-flight readiness audit (fails fast before build)
./scripts/preflight_check.sh                  # All platforms (Prod)
./scripts/preflight_check.sh ios prod         # iOS TestFlight check
./scripts/preflight_check.sh android prod     # Android Google Play check
./scripts/preflight_check.sh all uat          # UAT / Staging check

# Android: Generate release keystore & copy Base64 to clipboard
./scripts/generate_keystore.sh rexone upload

# Android: Copy Google Play Service Account JSON to clipboard
./scripts/copy_play_store_key.sh rexone

# Android: Local release builds (optional)
./scripts/release_android.sh prod --bundle    # Production .aab
./scripts/release_android.sh uat --bundle     # UAT staging .aab
./scripts/release_android.sh prod --apk       # Sideloadable APK

# iOS: Build and upload to TestFlight (macOS)
./scripts/release_ios.sh prod                 # Production TestFlight release
./scripts/release_ios.sh uat                  # UAT staging TestFlight release
./scripts/release_ios.sh prod --validate-only # Pre-validate without uploading
```
