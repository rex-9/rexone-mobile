#!/usr/bin/env bash
# scripts/release_ios.sh
# Automated local iOS build and TestFlight deployment via App Store Connect API
# Usage: ./scripts/release_ios.sh [prod|uat] [--build-only]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "❌ Error: iOS release builds must be run on macOS with Xcode installed."
  exit 1
fi

TARGET_ENV="prod"
BUILD_ONLY=false

for arg in "$@"; do
  case "$arg" in
    uat)
      TARGET_ENV="uat"
      ;;
    prod)
      TARGET_ENV="prod"
      ;;
    --build-only)
      BUILD_ONLY=true
      ;;
    -h|--help)
      echo "📱 iOS Release & TestFlight Publisher"
      echo "------------------------------------------------------------"
      echo "Usage: ./scripts/release_ios.sh [prod|uat] [--build-only]"
      echo ""
      echo "Options:"
      echo "  prod          Build using .env.prod (default)"
      echo "  uat           Build using .env.uat"
      echo "  --build-only  Compile the IPA without uploading to TestFlight"
      exit 0
      ;;
    *)
      ;;
  esac
done

echo "============================================================"
echo "🍎  REXONE IOS RELEASE & TESTFLIGHT DEPLOYER"
echo "============================================================"
echo "🎯 Target Environment: $TARGET_ENV"
echo "📦 Build Only:         $BUILD_ONLY"

# 1. Read app version from pubspec.yaml
RAW_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | tr -d '[:space:]')
VERSION_NAME=$(echo "$RAW_VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$RAW_VERSION" | cut -d'+' -f2)
echo "🏷️ App Version:        v${VERSION_NAME} (Build ${BUILD_NUMBER})"
echo "------------------------------------------------------------"

# 2. Check environment file
ENV_FILE=".env.${TARGET_ENV}"
if [ ! -f "$ENV_FILE" ]; then
  echo "⚠️ Warning: $ENV_FILE not found! Creating from .env.example..."
  if [ -f ".env.example" ]; then
    cp .env.example "$ENV_FILE"
  else
    touch "$ENV_FILE"
  fi
fi

# 3. Check App Store Connect credentials if uploading
if [ "$BUILD_ONLY" = false ]; then
  # Load from local secret file if present (~/.appstoreconnect/credentials or .env.appstore)
  if [ -f "$HOME/.appstoreconnect/credentials" ]; then
    # shellcheck disable=SC1090
    source "$HOME/.appstoreconnect/credentials"
  elif [ -f "$ROOT_DIR/.env.appstore" ]; then
    # shellcheck disable=SC1091
    source "$ROOT_DIR/.env.appstore"
  fi

  APP_STORE_KEY_ID="${APP_STORE_KEY_ID:-}"
  APP_STORE_ISSUER_ID="${APP_STORE_ISSUER_ID:-}"

  if [ -z "$APP_STORE_KEY_ID" ] || [ -z "$APP_STORE_ISSUER_ID" ]; then
    echo "⚠️ App Store Connect API Credentials missing."
    echo "   Provide them as environment variables, or save them in ~/.appstoreconnect/credentials:"
    echo "     export APP_STORE_KEY_ID=\"XXXXXXXXXX\""
    echo "     export APP_STORE_ISSUER_ID=\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx\""
    echo ""
    read -r -p "Enter App Store Connect Key ID (10 chars): " input_key_id
    read -r -p "Enter App Store Connect Issuer ID (UUID): " input_issuer_id
    APP_STORE_KEY_ID="${input_key_id:-$APP_STORE_KEY_ID}"
    APP_STORE_ISSUER_ID="${input_issuer_id:-$APP_STORE_ISSUER_ID}"
  fi

  if [ -z "$APP_STORE_KEY_ID" ] || [ -z "$APP_STORE_ISSUER_ID" ]; then
    echo "❌ Missing credentials. Run with '--build-only' to skip TestFlight upload."
    exit 1
  fi

  # Check private key file in standard locations
  KEY_FILE="$HOME/.appstoreconnect/private_keys/AuthKey_${APP_STORE_KEY_ID}.p8"
  ALT_KEY_FILE="$HOME/.private_keys/AuthKey_${APP_STORE_KEY_ID}.p8"

  if [ ! -f "$KEY_FILE" ] && [ ! -f "$ALT_KEY_FILE" ]; then
    echo "❌ Error: Private key file AuthKey_${APP_STORE_KEY_ID}.p8 not found!"
    echo "   Please place your downloaded .p8 key file at:"
    echo "     $KEY_FILE"
    echo "   or"
    echo "     $ALT_KEY_FILE"
    exit 1
  fi
fi

# 4. Clean & prepare Flutter dependencies
echo "📦 Resolving Flutter dependencies..."
flutter pub get

# 5. Build iOS Archive & IPA
echo "🔨 Building iOS Release IPA (Apple Silicon Native)..."
START_TIME=$(date +%s)

flutter build ipa --release \
  --dart-define="APP_ENV=$ENV_FILE"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo "✅ iOS Build completed in ${DURATION}s!"

# 6. Locate generated IPA
IPA_PATH=$(find "$ROOT_DIR/build/ios/ipa" -name "*.ipa" | head -n 1)

if [ -z "$IPA_PATH" ] || [ ! -f "$IPA_PATH" ]; then
  echo "❌ Error: Could not locate built .ipa in build/ios/ipa/"
  exit 1
fi

IPA_SIZE=$(du -h "$IPA_PATH" | cut -f1)
echo "📦 Generated IPA: $(basename "$IPA_PATH") ($IPA_SIZE)"
echo "   Path: $IPA_PATH"

# 7. Upload to TestFlight
if [ "$BUILD_ONLY" = true ]; then
  echo "🎉 Build finished successfully (--build-only specified). Skipped TestFlight upload."
  exit 0
fi

echo "🚀 Uploading to TestFlight via App Store Connect API..."
echo "   Key ID:    $APP_STORE_KEY_ID"
echo "   Issuer ID: $APP_STORE_ISSUER_ID"

xcrun altool --upload-app \
  --type ios \
  --file "$IPA_PATH" \
  --apiKey "$APP_STORE_KEY_ID" \
  --apiIssuer "$APP_STORE_ISSUER_ID"

echo "============================================================"
echo "🎉 SUCCESS: Uploaded v${VERSION_NAME} (Build ${BUILD_NUMBER}) to TestFlight!"
echo "👉 Check processing status at: https://appstoreconnect.apple.com/apps"
echo "============================================================"
