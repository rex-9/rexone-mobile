#!/usr/bin/env bash
# scripts/release_ios.sh
# Automated local iOS build and TestFlight deployment via App Store Connect API
# Usage: ./scripts/release_ios.sh [prod|uat] [--build-only] [--validate-only] [--build-number <num>]
# Example: ./scripts/release_ios.sh prod --build-only

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
VALIDATE_ONLY=false
BUILD_NUMBER_OVERRIDE="${BUILD_NUMBER:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    uat)
      TARGET_ENV="uat"
      shift
      ;;
    prod)
      TARGET_ENV="prod"
      shift
      ;;
    --build-only)
      BUILD_ONLY=true
      shift
      ;;
    --validate-only)
      VALIDATE_ONLY=true
      shift
      ;;
    --build-number)
      BUILD_NUMBER_OVERRIDE="$2"
      shift 2
      ;;
    -h|--help)
      echo "🍎 iOS Release & TestFlight Publisher"
      echo "------------------------------------------------------------"
      echo "Usage: ./scripts/release_ios.sh [prod|uat] [options]"
      echo ""
      echo "Options:"
      echo "  prod                  Build using .env.prod (default)"
      echo "  uat                   Build using .env.uat"
      echo "  --build-only          Compile IPA and prepare release artifact without uploading"
      echo "  --validate-only       Validate IPA with App Store Connect without uploading"
      echo "  --build-number <num>  Override build number (e.g. 15)"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

echo "============================================================"
echo "🍎  REXONE IOS RELEASE & TESTFLIGHT DEPLOYER"
echo "============================================================"
echo "🎯 Target Environment: $TARGET_ENV"
echo "📦 Build Only:         $BUILD_ONLY"
echo "🔍 Validate Only:      $VALIDATE_ONLY"

# 1. Read app version from pubspec.yaml
RAW_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | tr -d '[:space:]')
VERSION_NAME=$(echo "$RAW_VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$RAW_VERSION" | cut -d'+' -f2)
if [ -n "$BUILD_NUMBER_OVERRIDE" ]; then
  BUILD_NUMBER="$BUILD_NUMBER_OVERRIDE"
  echo "🔢 Build Number Override: $BUILD_NUMBER"
fi

PACKAGE_NAME="com.rex9.rexone"
APP_DISPLAY_NAME="RexOne"
if [ "$TARGET_ENV" = "uat" ]; then
  PACKAGE_NAME="com.rex9.rexone.uat"
  APP_DISPLAY_NAME="RexOne UAT"
fi

echo "🏷️ App Version:        v${VERSION_NAME} (Build ${BUILD_NUMBER})"
echo "📦 Target Package:     $PACKAGE_NAME"
echo "📱 App Display Name:   $APP_DISPLAY_NAME"
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

# 3. Check App Store Connect credentials if uploading or validating
if [ "$BUILD_ONLY" = false ]; then
  CREDS_FILE="$HOME/.appstoreconnect/credentials"
  if [ -f "$CREDS_FILE" ]; then
    # shellcheck disable=SC1090
    source "$CREDS_FILE"
  elif [ -f "$ROOT_DIR/.env.appstore" ]; then
    # shellcheck disable=SC1091
    source "$ROOT_DIR/.env.appstore"
  fi

  APP_STORE_KEY_ID="${APP_STORE_KEY_ID:-}"
  APP_STORE_ISSUER_ID="${APP_STORE_ISSUER_ID:-}"

  # Auto-discover Key ID from private_keys directory if not set
  if [ -z "$APP_STORE_KEY_ID" ]; then
    KEY_PATH=$(find "$HOME/.appstoreconnect/private_keys" "$HOME/.private_keys" -name "AuthKey_*.p8" 2>/dev/null | head -n 1 || true)
    if [ -n "$KEY_PATH" ]; then
      APP_STORE_KEY_ID=$(basename "$KEY_PATH" | sed -E 's/AuthKey_(.*)\.p8/\1/')
      echo "🔑 Auto-detected App Store Connect Key ID: $APP_STORE_KEY_ID"
    fi
  fi

  if [ -z "$APP_STORE_KEY_ID" ] || [ -z "$APP_STORE_ISSUER_ID" ]; then
    echo "⚠️ App Store Connect API Credentials missing."
    echo "   Provide them as environment variables, or save them in ~/.appstoreconnect/credentials:"
    echo "     export APP_STORE_KEY_ID=\"XXXXXXXXXX\""
    echo "     export APP_STORE_ISSUER_ID=\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx\""
    echo ""
    [ -z "$APP_STORE_KEY_ID" ] && read -r -p "Enter App Store Connect Key ID (10 chars): " APP_STORE_KEY_ID
    [ -z "$APP_STORE_ISSUER_ID" ] && read -r -p "Enter App Store Connect Issuer ID (UUID): " APP_STORE_ISSUER_ID

    if [ -n "$APP_STORE_KEY_ID" ] && [ -n "$APP_STORE_ISSUER_ID" ]; then
      read -r -p "Save to ~/.appstoreconnect/credentials for future builds? (y/N): " SAVE_CREDS
      if [[ "$SAVE_CREDS" =~ ^[Yy]$ ]]; then
        mkdir -p "$HOME/.appstoreconnect"
        cat <<EOF > "$CREDS_FILE"
export APP_STORE_KEY_ID="$APP_STORE_KEY_ID"
export APP_STORE_ISSUER_ID="$APP_STORE_ISSUER_ID"
EOF
        chmod 600 "$CREDS_FILE"
        echo "✅ Saved to $CREDS_FILE (strictly local, chmod 600)."
      fi
    fi
  fi

  if [ -z "$APP_STORE_KEY_ID" ] || [ -z "$APP_STORE_ISSUER_ID" ]; then
    echo "❌ Missing credentials. Run with '--build-only' to skip TestFlight upload."
    exit 1
  fi

  # Verify private key file in standard locations
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
  --build-name="$VERSION_NAME" \
  --build-number="$BUILD_NUMBER" \
  --dart-define="APP_ENV=$ENV_FILE" \
  --dart-define="TARGET_ENV=$TARGET_ENV"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo "------------------------------------------------------------"
echo "✅ iOS Build completed in ${DURATION}s!"

# 6. Locate generated IPA & organize to build/release-artifacts
RAW_IPA_PATH=$(find "$ROOT_DIR/build/ios/ipa" -name "*.ipa" 2>/dev/null | head -n 1 || true)
if [ -z "$RAW_IPA_PATH" ] && [ -d "$ROOT_DIR/build.nosync/ios/ipa" ]; then
  RAW_IPA_PATH=$(find "$ROOT_DIR/build.nosync/ios/ipa" -name "*.ipa" 2>/dev/null | head -n 1 || true)
fi

if [ -z "$RAW_IPA_PATH" ] || [ ! -f "$RAW_IPA_PATH" ]; then
  echo "❌ Error: Could not locate built .ipa in build/ios/ipa/"
  exit 1
fi

DEST_DIR="$ROOT_DIR/build/release-artifacts"
mkdir -p "$DEST_DIR"

IPA_NAME="rexone-${TARGET_ENV}-v${VERSION_NAME}-b${BUILD_NUMBER}.ipa"
FINAL_IPA_PATH="$DEST_DIR/$IPA_NAME"
cp "$RAW_IPA_PATH" "$FINAL_IPA_PATH"

IPA_SIZE=$(du -h "$FINAL_IPA_PATH" | cut -f1)

echo "============================================================"
echo "🎉 RELEASE ARTIFACT READY:"
echo "============================================================"
echo "📦 Apple IPA:       $FINAL_IPA_PATH ($IPA_SIZE)"
echo "   App:             $APP_DISPLAY_NAME ($PACKAGE_NAME)"
echo "   Version:         v${VERSION_NAME} (Build ${BUILD_NUMBER})"
echo "------------------------------------------------------------"

# Copy artifact path to clipboard on macOS
if command -v pbcopy &> /dev/null; then
  echo "$FINAL_IPA_PATH" | pbcopy
  echo "📋 Artifact path copied to clipboard!"
fi

# Reveal in Finder on macOS
if command -v open &> /dev/null; then
  open -R "$FINAL_IPA_PATH" 2>/dev/null || true
  echo "📂 Opened artifact folder in Finder for inspection."
fi

# 7. Check if build-only
if [ "$BUILD_ONLY" = true ]; then
  echo "============================================================"
  echo "🎉 Build finished successfully (--build-only specified). Skipped TestFlight upload."
  echo "============================================================"
  exit 0
fi

# 8. Pre-validate with App Store Connect
echo "============================================================"
echo "🔍 Validating IPA with App Store Connect..."
echo "============================================================"
xcrun altool --validate-app \
  --type ios \
  --file "$FINAL_IPA_PATH" \
  --apiKey "$APP_STORE_KEY_ID" \
  --apiIssuer "$APP_STORE_ISSUER_ID"

echo "✅ App Store Connect validation successful!"

if [ "$VALIDATE_ONLY" = true ]; then
  echo "🎉 Validation finished successfully (--validate-only specified)."
  exit 0
fi

# 9. Upload to TestFlight
echo "============================================================"
echo "🚀 Uploading to TestFlight via App Store Connect API..."
echo "============================================================"
echo "   Key ID:    $APP_STORE_KEY_ID"
echo "   Issuer ID: $APP_STORE_ISSUER_ID"

xcrun altool --upload-app \
  --type ios \
  --file "$FINAL_IPA_PATH" \
  --apiKey "$APP_STORE_KEY_ID" \
  --apiIssuer "$APP_STORE_ISSUER_ID"

echo "============================================================"
echo "🎉 SUCCESS: Uploaded v${VERSION_NAME} (Build ${BUILD_NUMBER}) to TestFlight!"
echo "👉 Check processing status at: https://appstoreconnect.apple.com/apps"
echo "============================================================"
