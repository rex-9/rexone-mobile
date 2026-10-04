# RexOne Mobile: Technical Documentation & Native Subsystem Reference

This directory serves as the technical documentation manual for **RexOne Mobile** (`rexone_mobile`), the sovereign Flutter 3 native iOS and Android client for the RexOne ecosystem.

---

## 📚 Documentation Index

| Guide | Description | Canonical Path |
| :--- | :--- | :--- |
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
| `./scripts/release_android.sh` | Compiles release Android App Bundle (.aab) or APK locally | `[prod\|uat] [--bundle\|--apk\|--all]` |
| `./scripts/release_ios.sh` | Builds release IPA locally and deploys to Apple TestFlight | `[prod\|uat] [--build-only]` |
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

RexOne Mobile implements a sovereign **hybrid release pipeline**:
- **Android**: Automated cloud build and store publication on GitHub Actions (`ubuntu-latest`).
- **iOS**: Apple Silicon local build and TestFlight upload via [`./scripts/release_ios.sh`](../scripts/release_ios.sh), preserving free GitHub Actions minutes.

### 🤖 Android Automated Pipeline (`.github/workflows/build_android.yaml`)
Triggered automatically on pushes to `uat` or `main`:
1. Sets up JDK 21 and Flutter SDK.
2. Injects `.env` secrets and `google-services.json`.
3. Injects and decodes release keystore from `ANDROID_KEYSTORE_BASE64`.
4. Compiles both `.apk` (for direct release download) and `.aab` (optimized App Bundle for Google Play).
5. Automatically tags GitHub release and attaches APK + AAB assets.
6. Publishes `.aab` directly to Google Play **Internal Testing** track via `r0adkll/upload-google-play@v1` if `PLAY_STORE_JSON_KEY` is present.

#### Required GitHub Secrets for Android:
| Secret Name | Description |
| :--- | :--- |
| `ENV_PROD` | Production environment file content (`.env.prod`) |
| `ENV_UAT` | UAT environment file content (`.env.uat`) |
| `ANDROID_GOOGLE_SERVICES_JSON` | Firebase `android/app/google-services.json` content (use `./scripts/copy_google_services_android.sh`) |
| `IOS_GOOGLE_SERVICES_PLIST` | Firebase `ios/Runner/GoogleService-Info.plist` content (use `./scripts/copy_google_services_ios.sh`) |
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded `upload-keystore.jks` (use `./scripts/copy_keystore_base64.sh`) |
| `KEYSTORE_PASSWORD` | Password for the release keystore |
| `KEY_ALIAS` | Key alias (e.g. `upload` or `rexone`) |
| `KEY_PASSWORD` | Password for the key alias |
| `PLAY_STORE_JSON_KEY` | Google Cloud Service Account JSON key for Play Developer API (use `./scripts/copy_play_store_key.sh`) |

#### 📁 Secure Local Key Organization
All release signing assets and store deployment keys are safely organized in local directories strictly excluded from git tracking (`.gitignore`):
- **`rexone_mobile/android/keystores/`**:
  - `rexone-upload-keystore.jks`: Android release upload signing keystore (used by both Prod and UAT)
  - `rexone-upload-cert.pem`: Public X.509 certificate for Play Console upload key registration / reset
  - `rexone-play-store-key.json`: Google Cloud Service Account JSON key for Google Play Developer API (GitHub Actions CI/CD)
  - `firebase-adminsdk-key.json`: Firebase Admin SDK Service Account JSON (uploaded to OneSignal for FCM v1 push notifications & backend admin)
- **Ecosystem Backup**: Mirrors in `Dev/rexone/keystores/` and `~/.android/keystores/` (zero risk of loss).

#### 📱 Dual-Package Store Architecture (Prod vs UAT)
RexOne Mobile implements side-by-side app store distribution allowing developers and QA testers to have both Production and UAT apps installed simultaneously on the same physical device:

| Environment | Public Display Name | Store Application ID | Deep Link Scheme | Config File |
| :--- | :--- | :--- | :--- | :--- |
| **Production** | `<App Name>` | `<com.company.app>` | `<scheme>://` | `.env.prod` |
| **UAT / Staging** | `<App Name> UAT` | `<com.company.app>.uat` | `<scheme>-uat://` | `.env.uat` |

##### Why `namespace` is Static while `applicationId` is Dynamic:
- **`namespace = "<com.company.app>"`**: In modern Android Gradle Plugin (AGP 8.0+), `namespace` defines the internal Kotlin/Java source package where generated `R` and `BuildConfig` classes live (`package <com.company.app>` in `MainActivity.kt`). It **must remain static** so Kotlin code compiles without requiring physical directory renames.
- **`defaultConfig.applicationId`**: This is the **only** identifier recognized by Android OS, Google Play, and Firebase. It is switched dynamically based on `TARGET_ENV`:
  ```kotlin
  applicationId = if (isUat) "<com.company.app>.uat" else "<com.company.app>"
  manifestPlaceholders["appName"] = if (isUat) "<App Name> UAT" else "<App Name>"
  manifestPlaceholders["deepLinkScheme"] = if (isUat) "<scheme>-uat" else "<scheme>"
  ```
- **Firebase Dual-Client Integration**: A single `android/app/google-services.json` contains configuration entries for both `<com.company.app>` and `<com.company.app>.uat`. The Google Services Gradle plugin matches the active `applicationId` at build time.

### 🍎 iOS Local Pipeline (`scripts/release_ios.sh`)
Builds and deploys to TestFlight directly from macOS terminal using official App Store Connect API keys (`.p8`):

```bash
# Production TestFlight release
./scripts/release_ios.sh prod

# Staging / UAT TestFlight release
./scripts/release_ios.sh uat

# Compile IPA locally without uploading to Apple
./scripts/release_ios.sh prod --build-only
```

#### Local Credential Setup:
1. Store credentials in `~/.appstoreconnect/credentials`:
   ```bash
   export APP_STORE_KEY_ID="XXXXXXXXXX"
   export APP_STORE_ISSUER_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   ```
2. Place private key `.p8` in `~/.appstoreconnect/private_keys/`:
   ```bash
   ~/.appstoreconnect/private_keys/AuthKey_<APP_STORE_KEY_ID>.p8
   ```

### 🔨 Manual Local Compilations
```bash
# Android Release APK
flutter build apk --release --dart-define=APP_ENV=.env.prod

# Android App Bundle (Google Play AAB)
flutter build appbundle --release --dart-define=APP_ENV=.env.prod

# iOS Release IPA
flutter build ipa --release --dart-define=APP_ENV=.env.prod
```
