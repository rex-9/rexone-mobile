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
├── constants/            # Constants, analytics event keys, locale keys, HTTP status
├── controllers/          # App-wide coordinators only (SocketController)
├── database/             # Drift SQLite database (rexone_offline), tables, DAOs, and migrations
├── design/               # Design system tokens, reusable UI primitives, and themes
│   ├── components/       # Buttons, Inputs, Password fields, Dialogs, Loading indicators, Snackbars
│   ├── elements/         # Design tokens (Colors, Spacing, Typography, Icons, Timers)
│   └── extensions/       # Theme context extensions (context.colors, context.typo)
├── helpers/              # Utility helpers (JSON:API parser, validators, media encryption)
├── locales/              # Multi-language translations (English en_US, Burmese my_MM)
├── models/               # Strongly typed JSON:API models and response envelopes
├── modules/              # Cohesive feature modules (Page + Controller + Feature Service)
│   ├── splash/           # Launch, session restoration, blocking version upgrade
│   ├── auth/             # Welcome, smart email discovery, 6-digit password, OTP, recovery
│   ├── home/             # Main dashboard, quick actions, and upgrade prompts
│   ├── payment/          # Product catalogue, coupon validation, Stripe Checkout WebView
│   ├── profile/          # Account profile management, avatar camera/gallery upload
│   ├── setting/          # Theme toggle, language switcher, and account navigation
│   ├── ai/               # Non-blocking queued AI chat, multi-room management, live thinking
│   └── media/            # Mixed media library, dual players, offline downloads
│       ├── components/   # TrackArtwork, playlist tile/header/empty/load-more
│       ├── controllers/  # MediaPlaylistController (library + bulk downloads)
│       ├── pages/        # MediaPlaylistPage
│       ├── audio/        # Full player, mini player, synced lyrics (SRT)
│       └── video/        # Inline better_player, viewport sizing, subtitle tracks
├── routes/               # GetX route declarations and auth route guards
└── services/             # Shared transport gateways (API, SolidCable, Analytics, Push, Log)
```

### Layer Boundaries:
- **Presentation (`lib/modules/*/pages/`, `lib/design/`)**: Pure UI widgets. Widgets never instantiate transport clients, mutate storage directly, or execute business logic.
- **Business Logic (`lib/modules/*/controllers/`)**: Reactive GetX controllers managing feature state, user gestures, and coordinating with services.
- **Data & Transport (`lib/services/`, `lib/models/`)**: Strongly typed models, JSON:API response envelopes, and single-responsibility transport clients.
- **Local Persistence (`lib/database/`)**: Type-safe Drift SQLite database (`rexone_offline`) mirroring backend tables for resilient local-first operation.

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

RexOne Mobile includes an automated Android release pipeline in [`.github/workflows/build_android.yaml`](../.github/workflows/build_android.yaml):

### Automated GitHub Actions Workflow
- **UAT Pipeline (`uat` branch)**:
  - Injects `ENV_UAT` secret into `.env.uat`.
  - Builds release APK: `flutter build apk --release --dart-define=APP_ENV=.env.uat`.
  - Automatically tags pre-release `v${VERSION}-uat+${BUILD}` with APK attached.
- **Production Pipeline (`main` branch)**:
  - Injects `ENV_PROD` secret into `.env.prod`.
  - Builds release APK: `flutter build apk --release --dart-define=APP_ENV=.env.prod`.
  - Automatically tags production release `v${VERSION}+${BUILD}` with release APK attached.

### Manual Release Compilation
```bash
# Build Android APK (Release)
flutter build apk --release --dart-define=APP_ENV=.env.prod

# Build Android App Bundle (Google Play AAB)
flutter build appbundle --release --dart-define=APP_ENV=.env.prod

# Build iOS Release Archive
flutter build ios --release --dart-define=APP_ENV=.env.prod
```
