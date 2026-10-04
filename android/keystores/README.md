# Android Keystores & Release Publishing Keys

This directory holds local Android release signing keystores and Google Play Store deployment keys.

> [!WARNING]
> Real credentials (`*.jks`, `*.pem`, `*.json`) are **strictly excluded from git control** via `.gitignore`.
> Only template example files (`*.example`, `README.md`) may be committed for developer reference.

---

## 📁 File Structure

| File | Purpose | Committed to Git? |
| :--- | :--- | :--- |
| `rexone-upload-keystore.jks` | 2048-bit RSA release upload keystore for Android | ❌ Gitignored |
| `rexone-upload-cert.pem` | Public X.509 certificate for Google Play upload verification | ❌ Gitignored |
| `rexone-play-store-key.json` | Google Cloud Service Account JSON for Google Play Developer API | ❌ Gitignored |
| `firebase-adminsdk-key.json` | Firebase Admin SDK Service Account JSON (backend/admin automation) | ❌ Gitignored |
| `play-store-key.json.example` | Template schema for Google Play Service Account JSON | ✅ Committed |
| `firebase-adminsdk-key.json.example` | Template schema for Firebase Admin SDK Service Account JSON | ✅ Committed |
| `upload-keystore.jks.example` | Dummy 2048-bit RSA keystore for testing local builds | ✅ Committed |
| `upload-cert.pem.example` | Template format for public upload certificate | ✅ Committed |
| `key.properties.example` | Template for local Gradle release signing properties | ✅ Committed |

---

## 🛠️ CLI Generation & Management

### Generate a new upload keystore:
```bash
# Generates ~/.android/keystores/ and copies to keystores/ and clipboard
./scripts/generate_keystore.sh rexone upload
```

### Re-copy Base64 keystore to clipboard:
```bash
./scripts/copy_keystore_base64.sh rexone
```

### Re-copy Google Play JSON key to clipboard:
```bash
./scripts/copy_play_store_key.sh rexone
```

### Re-copy Google Services JSON (Android) to clipboard:
```bash
./scripts/copy_google_services_android.sh
```

### Re-copy Google Service Info plist (iOS) to clipboard:
```bash
./scripts/copy_google_services_ios.sh
```

### Build Android release locally:
```bash
# Build production App Bundle (.aab for Google Play)
./scripts/release_android.sh prod --bundle

# Build release APK
./scripts/release_android.sh prod --apk
```

---

## 🔐 GitHub Actions Secrets Mapping

| Local File / Value | Target GitHub Secret | Purpose |
| :--- | :--- | :--- |
| `base64 < android/keystores/rexone-upload-keystore.jks` | `ANDROID_KEYSTORE_BASE64` | Decoded on runner for release signing (use `./scripts/copy_keystore_base64.sh`) |
| Keystore Password | `KEYSTORE_PASSWORD` | Password for `.jks` file |
| Key Alias (`upload`) | `KEY_ALIAS` | Alias name inside `.jks` |
| Key Password | `KEY_PASSWORD` | Password for the key alias |
| `android/keystores/rexone-play-store-key.json` | `PLAY_STORE_JSON_KEY` | Play Developer API authentication (use `./scripts/copy_play_store_key.sh`) |
| `android/app/google-services.json` | `ANDROID_GOOGLE_SERVICES_JSON` | Firebase Android configuration (use `./scripts/copy_google_services_android.sh`) |
| `ios/Runner/GoogleService-Info.plist` | `IOS_GOOGLE_SERVICES_PLIST` | Firebase iOS configuration (use `./scripts/copy_google_services_ios.sh`) |
