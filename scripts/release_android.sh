#!/usr/bin/env bash
# scripts/release_android.sh
# Automated local Android release builder (App Bundle & APK)
# Usage: ./scripts/release_android.sh [prod|uat] [--bundle|--apk|--all]
# Example: ./scripts/release_android.sh prod --bundle

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

# Ensure JDK 21 is discovered on macOS if JAVA_HOME is not explicitly set
if [ -z "${JAVA_HOME:-}" ]; then
  if [ -x "/usr/libexec/java_home" ]; then
    DETECTED_JAVA="$(/usr/libexec/java_home -v 21 2>/dev/null || /usr/libexec/java_home 2>/dev/null || true)"
    if [ -n "$DETECTED_JAVA" ]; then
      export JAVA_HOME="$DETECTED_JAVA"
    fi
  elif [ -d "/opt/homebrew/opt/openjdk@21" ]; then
    export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
  fi
fi

TARGET_ENV="prod"
BUILD_MODE="bundle" # options: bundle, apk, all
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
    --bundle)
      BUILD_MODE="bundle"
      shift
      ;;
    --apk)
      BUILD_MODE="apk"
      shift
      ;;
    --all)
      BUILD_MODE="all"
      shift
      ;;
    --build-number)
      BUILD_NUMBER_OVERRIDE="$2"
      shift 2
      ;;
    -h|--help)
      echo "🤖 Android Release Builder"
      echo "------------------------------------------------------------"
      echo "Usage: ./scripts/release_android.sh [prod|uat] [--bundle|--apk|--all] [--build-number <num>]"
      echo ""
      echo "Options:"
      echo "  prod                  Build using .env.prod (default)"
      echo "  uat                   Build using .env.uat"
      echo "  --bundle              Build Android App Bundle (.aab for Google Play, default)"
      echo "  --apk                 Build Release APK (for direct download)"
      echo "  --all                 Build both .aab and .apk"
      echo "  --build-number <num>  Override build number (e.g. 15)"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

APP_SLUG="rexone"
PACKAGE_BASE="com.rex9.rexone"
DEFAULT_APP_BASE="RexOne"

APP_DISPLAY_NAME="$DEFAULT_APP_BASE"
PACKAGE_NAME="$PACKAGE_BASE"
if [ "$TARGET_ENV" = "uat" ]; then
  PACKAGE_NAME="${PACKAGE_BASE}.uat"
  APP_DISPLAY_NAME="${DEFAULT_APP_BASE} UAT"
fi

BUILD_BANNER=$(echo "$APP_DISPLAY_NAME Android Release Builder" | tr '[:lower:]' '[:upper:]')
echo "============================================================"
echo "🤖  $BUILD_BANNER"
echo "============================================================"
echo "🎯 Target Environment: $TARGET_ENV"
echo "📦 Build Target:       $BUILD_MODE"

# 1. Read app version from pubspec.yaml
RAW_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | tr -d '[:space:]')
VERSION_NAME=$(echo "$RAW_VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$RAW_VERSION" | cut -d'+' -f2)
if [ -n "$BUILD_NUMBER_OVERRIDE" ]; then
  BUILD_NUMBER="$BUILD_NUMBER_OVERRIDE"
  echo "🔢 Build Number Override: $BUILD_NUMBER"
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

# 3. Check for release signing credentials
KEY_PROPS="android/key.properties"
KEYSTORE_FILE="android/keystores/${APP_SLUG}-upload-keystore.jks"
if [ -f "$KEY_PROPS" ]; then
  echo "🔐 Release signing configured via $KEY_PROPS."
elif [ -n "${KEYSTORE_PASSWORD:-}" ]; then
  echo "🔐 Release signing password detected from environment."
elif [ -f "$KEYSTORE_FILE" ]; then
  echo "🔐 Release keystore found: $KEYSTORE_FILE"
  echo "   Password is required to sign this release build."
  read -r -s -p "Enter Keystore Password: " ENTERED_PASS
  echo ""
  if [ -n "$ENTERED_PASS" ]; then
    export KEYSTORE_PASSWORD="$ENTERED_PASS"
    export KEY_PASSWORD="${KEY_PASSWORD:-$ENTERED_PASS}"
    read -r -p "Save to android/key.properties (gitignored) for future automated builds? (y/N): " SAVE_PROPS
    if [[ "$SAVE_PROPS" =~ ^[Yy]$ ]]; then
      cat <<EOF > "$KEY_PROPS"
storePassword=$ENTERED_PASS
keyPassword=$ENTERED_PASS
keyAlias=upload
storeFile=../keystores/${APP_SLUG}-upload-keystore.jks
EOF
      chmod 600 "$KEY_PROPS"
      echo "✅ Saved to $KEY_PROPS (strictly gitignored)."
    fi
  else
    echo "❌ Error: Keystore password cannot be empty for release builds."
    exit 1
  fi
else
  echo "❌ Error: Release keystore not found in $KEYSTORE_FILE"
  exit 1
fi

# 4. Resolve dependencies
echo "📦 Resolving Flutter dependencies..."
flutter pub get

START_TIME=$(date +%s)
export TARGET_ENV="$TARGET_ENV"

# 5. Build selected target(s)
if [ "$BUILD_MODE" = "bundle" ] || [ "$BUILD_MODE" = "all" ]; then
  echo "🔨 Building Android App Bundle (AAB for Google Play)..."
  flutter build appbundle --release \
    --build-name="$VERSION_NAME" \
    --build-number="$BUILD_NUMBER" \
    --dart-define="APP_ENV=$ENV_FILE" \
    --dart-define="TARGET_ENV=$TARGET_ENV"
fi

if [ "$BUILD_MODE" = "apk" ] || [ "$BUILD_MODE" = "all" ]; then
  echo "🔨 Building Android Release APK..."
  flutter build apk --release \
    --build-name="$VERSION_NAME" \
    --build-number="$BUILD_NUMBER" \
    --dart-define="APP_ENV=$ENV_FILE" \
    --dart-define="TARGET_ENV=$TARGET_ENV"
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo "------------------------------------------------------------"
echo "✅ Android build finished in ${DURATION}s!"

# 6. Locate artifacts & display summary
RAW_AAB_PATH="$ROOT_DIR/build/app/outputs/bundle/release/app-release.aab"
RAW_APK_PATH="$ROOT_DIR/build/app/outputs/flutter-apk/app-release.apk"

# Fallback for macOS iCloud .nosync build directories
if [ ! -f "$RAW_AAB_PATH" ] && [ -f "$ROOT_DIR/build.nosync/app/outputs/bundle/release/app-release.aab" ]; then
  RAW_AAB_PATH="$ROOT_DIR/build.nosync/app/outputs/bundle/release/app-release.aab"
fi
if [ ! -f "$RAW_APK_PATH" ] && [ -f "$ROOT_DIR/build.nosync/app/outputs/flutter-apk/app-release.apk" ]; then
  RAW_APK_PATH="$ROOT_DIR/build.nosync/app/outputs/flutter-apk/app-release.apk"
fi

DEST_DIR="$ROOT_DIR/build/release-artifacts"
mkdir -p "$DEST_DIR"

AAB_NAME="${APP_SLUG}-${TARGET_ENV}-v${VERSION_NAME}-b${BUILD_NUMBER}.aab"
APK_NAME="${APP_SLUG}-${TARGET_ENV}-v${VERSION_NAME}-b${BUILD_NUMBER}.apk"
AAB_PATH="$DEST_DIR/$AAB_NAME"
APK_PATH="$DEST_DIR/$APK_NAME"

if [ -f "$RAW_AAB_PATH" ]; then
  cp "$RAW_AAB_PATH" "$AAB_PATH"
fi
if [ -f "$RAW_APK_PATH" ]; then
  cp "$RAW_APK_PATH" "$APK_PATH"
fi

echo "============================================================"
echo "🎉 RELEASE ARTIFACTS READY:"
echo "============================================================"

PRIMARY_FILE=""
if [ -f "$AAB_PATH" ]; then
  AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
  echo "📦 Google Play AAB: $AAB_PATH ($AAB_SIZE)"
  echo "   App:             $APP_DISPLAY_NAME ($PACKAGE_NAME)"
  PRIMARY_FILE="$AAB_PATH"
fi

if [ -f "$APK_PATH" ]; then
  APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
  echo "📱 Release APK:     $APK_PATH ($APK_SIZE)"
  [ -z "$PRIMARY_FILE" ] && PRIMARY_FILE="$APK_PATH"
fi

if [ -n "$PRIMARY_FILE" ]; then
  echo "------------------------------------------------------------"
  # Copy artifact path to clipboard on macOS
  if [[ "$OSTYPE" == "darwin"* ]] && command -v pbcopy &> /dev/null; then
    echo "$PRIMARY_FILE" | pbcopy
    echo "📋 Artifact path copied to clipboard!"
  fi

  # Reveal in Finder on macOS
  if [[ "$OSTYPE" == "darwin"* ]] && command -v open &> /dev/null; then
    open -R "$PRIMARY_FILE" 2>/dev/null || true
    echo "📂 Opened artifact folder in Finder for drag-and-drop upload."
  fi
fi

echo "============================================================"
echo "👉 Upload your AAB to Google Play Console:"
echo "   https://play.google.com/console"
echo "============================================================"
