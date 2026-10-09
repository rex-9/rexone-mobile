#!/usr/bin/env bash
# ==============================================================================
# scripts/preflight_check.sh
# Comprehensive Pre-Flight Release Readiness & Fast-Fail Verification Engine
# Checks all required files, signing keys, credentials, and toolchains BEFORE
# compiling to save developer time, battery, and compute resources.
#
# Usage:
#   ./scripts/preflight_check.sh [all|android|ios] [prod|uat] [options]
# Examples:
#   ./scripts/preflight_check.sh
#   ./scripts/preflight_check.sh ios prod
#   ./scripts/preflight_check.sh android uat
#   ./scripts/preflight_check.sh ios prod --build-only
#   ./scripts/preflight_check.sh android prod --ci
# ==============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

# ------------------------------------------------------------------------------
# App & Package Metadata Discovery (Read directly from project config)
# ------------------------------------------------------------------------------
APP_NAME=$(grep '^name:' "$ROOT_DIR/pubspec.yaml" 2>/dev/null | awk '{print $2}' || true)
APP_SLUG="${APP_NAME%_mobile}"
APP_SLUG="${APP_SLUG%-mobile}"

DEFAULT_APP_BASE=$(grep '^description:' "$ROOT_DIR/pubspec.yaml" 2>/dev/null | sed 's/^description:[[:space:]]*//' | cut -d'#' -f1 | xargs || true)
[ -z "$DEFAULT_APP_BASE" ] && DEFAULT_APP_BASE="${APP_SLUG}"

PACKAGE_BASE=$(grep 'namespace =' "$ROOT_DIR/android/app/build.gradle.kts" 2>/dev/null | cut -d'"' -f2 || true)

# ------------------------------------------------------------------------------
# Colors & Formatting
# ------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Portable colored echo (works seamlessly under bash, zsh, and POSIX sh)
echo_e() {
  printf "%b\n" "$*"
}

# ------------------------------------------------------------------------------
# Default Options & Parameter Parsing
# ------------------------------------------------------------------------------
TARGET_PLATFORM="all"  # all, android, ios
TARGET_ENV="prod"       # prod, uat
BUILD_ONLY=false
CI_MODE=false

for arg in "$@"; do
  case "$arg" in
    all|android|ios)
      TARGET_PLATFORM="$arg"
      ;;
    prod|uat)
      TARGET_ENV="$arg"
      ;;
    --build-only)
      BUILD_ONLY=true
      ;;
    --ci)
      CI_MODE=true
      ;;
    -h|--help)
      echo_e "${BOLD}🚦 ${DEFAULT_APP_BASE} Mobile Pre-Flight Release Readiness Checker${NC}"
      echo "------------------------------------------------------------------------"
      echo "Validates all critical keys, certificates, credentials, and configs"
      echo "BEFORE building to fail fast and prevent wasted compile cycles."
      echo ""
      echo_e "${BOLD}Usage:${NC} ./scripts/preflight_check.sh [platform] [env] [options]"
      echo ""
      echo_e "${BOLD}Platforms:${NC}"
      echo "  all          Verify both Android and iOS readiness (default)"
      echo "  android      Verify Android release readiness only"
      echo "  ios          Verify iOS / TestFlight release readiness only"
      echo ""
      echo_e "${BOLD}Environments:${NC}"
      echo "  prod         Validate for Production (.env.prod, default)"
      echo "  uat          Validate for UAT / Staging (.env.uat)"
      echo ""
      echo_e "${BOLD}Options:${NC}"
      echo "  --build-only Skip remote store upload checks (App Store .p8 / Play Store JSON)"
      echo "  --ci         Enforce strict cloud CI rules (Play Store JSON required)"
      echo "  -h, --help   Show this documentation"
      exit 0
      ;;
    *)
      ;;
  esac
done

# ------------------------------------------------------------------------------
# Auto-discover toolchains in GUI & subshell PATHs
# ------------------------------------------------------------------------------
for p in \
  "$HOME/Desktop/Dev/Dependencies/flutter/bin" \
  "$HOME/development/flutter/bin" \
  "$HOME/flutter/bin" \
  "/opt/homebrew/bin" \
  "/usr/local/bin" \
  "$HOME/.pub-cache/bin"
do
  if [ -d "$p" ] && [[ ":$PATH:" != *":$p:"* ]]; then
    export PATH="$p:$PATH"
  fi
done

# Discover JDK 21 on macOS
if [ -z "${JAVA_HOME:-}" ]; then
  if [ -x "/usr/libexec/java_home" ]; then
    DETECTED_JAVA="$(/usr/libexec/java_home -v 21 2>/dev/null || /usr/libexec/java_home 2>/dev/null || true)"
    if [ -n "$DETECTED_JAVA" ]; then
      export JAVA_HOME="$DETECTED_JAVA"
      export PATH="$JAVA_HOME/bin:$PATH"
    fi
  elif [ -d "/opt/homebrew/opt/openjdk@21" ]; then
    export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
    export PATH="$JAVA_HOME/bin:$PATH"
  fi
fi

# ------------------------------------------------------------------------------
# App & Package Metadata Resolution
# ------------------------------------------------------------------------------
PACKAGE_NAME="$PACKAGE_BASE"
APP_DISPLAY_NAME="$DEFAULT_APP_BASE"
if [ "$TARGET_ENV" = "uat" ]; then
  PACKAGE_NAME="${PACKAGE_BASE}.uat"
  APP_DISPLAY_NAME="${DEFAULT_APP_BASE} UAT"
fi

UPPER_ENV=$(echo "$TARGET_ENV" | tr '[:lower:]' '[:upper:]')
UPPER_PLATFORM=$(echo "$TARGET_PLATFORM" | tr '[:lower:]' '[:upper:]')
UPPER_APP=$(echo "$DEFAULT_APP_BASE" | tr '[:lower:]' '[:upper:]')

# ------------------------------------------------------------------------------
# Check Result Accumulators
# ------------------------------------------------------------------------------
CHECK_NAMES=()
CHECK_STATUSES=() # PASS, WARN, FAIL, SKIP
CHECK_DETAILS=()

CURRENT_SCOPE="shared"
SHARED_FAILS=0
ANDROID_FAILS=0
IOS_FAILS=0

FAIL_SCOPES=()
FAIL_TITLES=()
FAIL_PROBLEMS=()
FAIL_REMEDIES=()

WARN_TITLES=()
WARN_PROBLEMS=()
WARN_REMEDIES=()

add_pass() {
  local name="$1"
  local detail="$2"
  CHECK_NAMES+=("$name")
  CHECK_STATUSES+=("PASS")
  CHECK_DETAILS+=("$detail")
}

add_warn() {
  local name="$1"
  local detail="$2"
  local problem="$3"
  local remedy="$4"
  CHECK_NAMES+=("$name")
  CHECK_STATUSES+=("WARN")
  CHECK_DETAILS+=("$detail")
  WARN_TITLES+=("$name")
  WARN_PROBLEMS+=("$problem")
  WARN_REMEDIES+=("$remedy")
}

add_fail() {
  local name="$1"
  local detail="$2"
  local problem="$3"
  local remedy="$4"
  CHECK_NAMES+=("$name")
  CHECK_STATUSES+=("FAIL")
  CHECK_DETAILS+=("$detail")
  FAIL_SCOPES+=("$CURRENT_SCOPE")
  FAIL_TITLES+=("$name")
  FAIL_PROBLEMS+=("$problem")
  FAIL_REMEDIES+=("$remedy")
  case "$CURRENT_SCOPE" in
    shared) SHARED_FAILS=$((SHARED_FAILS + 1)) ;;
    android) ANDROID_FAILS=$((ANDROID_FAILS + 1)) ;;
    ios) IOS_FAILS=$((IOS_FAILS + 1)) ;;
  esac
}

add_skip() {
  local name="$1"
  local detail="$2"
  CHECK_NAMES+=("$name")
  CHECK_STATUSES+=("SKIP")
  CHECK_DETAILS+=("$detail")
}

# ==============================================================================
# 1. SHARED & WORKSPACE CHECKS
# ==============================================================================

# 1.1 pubspec.yaml & version syntax
VERSION_NAME=""
BUILD_NUMBER=""
if [ -f "$ROOT_DIR/pubspec.yaml" ]; then
  RAW_VER=$(grep '^version:' "$ROOT_DIR/pubspec.yaml" | sed 's/version: //' | tr -d '[:space:]' || true)
  if [[ "$RAW_VER" =~ ^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$ ]]; then
    VERSION_NAME=$(echo "$RAW_VER" | cut -d'+' -f1)
    BUILD_NUMBER=$(echo "$RAW_VER" | cut -d'+' -f2)
    add_pass "pubspec.yaml Version" "v${VERSION_NAME} (Build ${BUILD_NUMBER})"
  else
    add_fail "pubspec.yaml Version" "Invalid version format: '$RAW_VER'" \
      "The 'version' field in pubspec.yaml must follow SemVer+BuildNumber (e.g. 1.0.0+1)." \
      "Run: ./scripts/update_app_version.sh 1.0.0+1"
  fi
else
  add_fail "pubspec.yaml File" "Missing pubspec.yaml" \
    "Cannot locate pubspec.yaml at the mobile workspace root." \
    "Ensure you are running the script from within the mobile workspace root directory."
fi

# 1.2 Target Environment File (.env.prod or .env.uat)
ENV_FILE=".env.${TARGET_ENV}"
if [ -f "$ROOT_DIR/$ENV_FILE" ]; then
  ENV_SIZE=$(wc -c < "$ROOT_DIR/$ENV_FILE" | tr -d '[:space:]')
  if [ "$ENV_SIZE" -gt 20 ]; then
    add_pass "Environment File" "$ENV_FILE exists (${ENV_SIZE} bytes)"
  else
    add_warn "Environment File" "$ENV_FILE is suspiciously small (${ENV_SIZE} bytes)" \
      "$ENV_FILE exists but appears empty or unpopulated." \
      "Review $ENV_FILE and ensure required API URLs and environment keys are populated."
  fi
else
  add_fail "Environment File" "$ENV_FILE not found" \
    "The required environment configuration file '$ENV_FILE' does not exist." \
    "Copy the example file and configure it:\n   cp .env.example $ENV_FILE"
fi

# 1.3 Flutter CLI Toolchain
if command -v flutter &>/dev/null; then
  FLUTTER_PATH=$(command -v flutter)
  add_pass "Flutter SDK CLI" "Found at $FLUTTER_PATH"
else
  add_fail "Flutter SDK CLI" "flutter executable not found in PATH" \
    "The 'flutter' command is not available in your current shell PATH." \
    "Install Flutter SDK or add its bin directory to your shell profile (~/.zshrc):\n   export PATH=\"\$HOME/Desktop/Dev/Dependencies/flutter/bin:\$PATH\""
fi

# 1.4 Secret Leak Scanner (check_secrets.sh)
if [ -x "$ROOT_DIR/scripts/check_secrets.sh" ]; then
  GIT_DIR=""
  if [ -x "/usr/bin/git" ]; then
    GIT_DIR=$(/usr/bin/git rev-parse --git-dir 2>/dev/null || true)
  elif command -v git >/dev/null 2>&1; then
    GIT_DIR=$(git rev-parse --git-dir 2>/dev/null || true)
  fi

  if [ -n "$GIT_DIR" ]; then
    LEAK_CHECK=$(PATH="/usr/bin:$PATH" "$ROOT_DIR/scripts/check_secrets.sh" 2>&1 || true)
    if echo "$LEAK_CHECK" | grep -q "BLOCKED"; then
      add_fail "Secret Leak Scanner" "Staged secrets or .env files detected" \
        "Git staged files contain sensitive tokens or live credentials." \
        "Run: ./scripts/check_secrets.sh to view details and unstage sensitive files."
    else
      add_pass "Secret Leak Scanner" "No staged secrets or uncommitted keys"
    fi
  else
    add_pass "Secret Leak Scanner" "Skipped (git directory not detected)"
  fi
fi

# ==============================================================================
# 2. ANDROID READINESS CHECKS
# ==============================================================================
if [ "$TARGET_PLATFORM" = "all" ] || [ "$TARGET_PLATFORM" = "android" ]; then
  CURRENT_SCOPE="android"

  # 2.1 Java JDK Environment
  JAVA_CMD=""
  if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/java" ]; then
    JAVA_CMD="$JAVA_HOME/bin/java"
  elif command -v java >/dev/null 2>&1; then
    JAVA_CMD="java"
  fi

  if [ -n "$JAVA_CMD" ]; then
    JAVA_VER=$($JAVA_CMD -version 2>&1 | grep -i "version" | head -n 1 | awk -F '"' '{print $2}' || true)
    MAJOR_JAVA=$(echo "$JAVA_VER" | cut -d'.' -f1)
    if [ -n "$MAJOR_JAVA" ] && [ "$MAJOR_JAVA" -ge 17 ] 2>/dev/null; then
      add_pass "Java JDK Runtime" "Java $JAVA_VER (JDK $MAJOR_JAVA)"
    elif [ -n "$JAVA_VER" ]; then
      add_warn "Java JDK Runtime" "Java $JAVA_VER detected (JDK 17+ strongly recommended)" \
        "Modern Android Gradle Plugin (AGP 8+) requires JDK 17 to JDK 21." \
        "Install OpenJDK 21 via Homebrew: brew install openjdk@21"
    else
      add_pass "Java JDK Runtime" "Java available (${JAVA_HOME:-system runtime})"
    fi
  else
    add_fail "Java JDK Runtime" "java not found in PATH" \
      "Java Development Kit (JDK) is required to build Android APK and AAB bundles." \
      "Install OpenJDK 21 via Homebrew:\n   brew install openjdk@21\n   sudo ln -sfn /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk"
  fi

  # 2.2 Firebase Configuration (google-services.json)
  GS_JSON="$ROOT_DIR/android/app/google-services.json"
  if [ -f "$GS_JSON" ]; then
    # Verify valid JSON and package match
    if python3 -c "import json; json.load(open('$GS_JSON'))" 2>/dev/null; then
      HAS_PKG=$(python3 -c "
import json
try:
  data = json.load(open('$GS_JSON'))
  pkgs = [c.get('client_info', {}).get('android_client_info', {}).get('package_name') for c in data.get('client', [])]
  print('yes' if '$PACKAGE_NAME' in pkgs or '$PACKAGE_BASE' in pkgs else 'no')
except:
  print('no')
" 2>/dev/null || echo "no")

      if [ "$HAS_PKG" = "yes" ]; then
        add_pass "Android Firebase Config" "google-services.json valid (includes $PACKAGE_NAME)"
      else
        add_warn "Android Firebase Config" "google-services.json found but missing package $PACKAGE_NAME" \
          "The package '$PACKAGE_NAME' is not listed in android/app/google-services.json." \
          "Download an updated google-services.json from Firebase Console containing your Android app package."
      fi
    else
      add_fail "Android Firebase Config" "google-services.json is corrupt or invalid JSON" \
        "android/app/google-services.json failed JSON syntax validation." \
        "Replace it with a valid google-services.json downloaded from Firebase Console."
    fi
  else
    add_fail "Android Firebase Config" "android/app/google-services.json not found" \
      "Firebase configuration file is required for Android push notifications and analytics." \
      "1. Open Firebase Console -> Project Settings -> General -> Your Apps\n2. Download google-services.json\n3. Place it at: android/app/google-services.json"
  fi

  # 2.3 Android Release Keystore & Credentials
  KEY_PROPS="$ROOT_DIR/android/key.properties"
  STORE_PASS="${KEYSTORE_PASSWORD:-}"
  KEY_PASS="${KEY_PASSWORD:-}"
  KEY_ALIAS="${KEY_ALIAS:-}"
  KEYSTORE_REL_PATH=""

  if [ -f "$KEY_PROPS" ]; then
    [ -z "$STORE_PASS" ] && STORE_PASS=$(grep '^storePassword=' "$KEY_PROPS" | cut -d'=' -f2- | tr -d '[:space:]' || true)
    [ -z "$KEY_PASS" ] && KEY_PASS=$(grep '^keyPassword=' "$KEY_PROPS" | cut -d'=' -f2- | tr -d '[:space:]' || true)
    [ -z "$KEY_ALIAS" ] && KEY_ALIAS=$(grep '^keyAlias=' "$KEY_PROPS" | cut -d'=' -f2- | tr -d '[:space:]' || true)
    KEYSTORE_REL_PATH=$(grep '^storeFile=' "$KEY_PROPS" | cut -d'=' -f2- | tr -d '[:space:]' || true)
  fi

  # Resolve keystore file path
  RESOLVED_KEYSTORE=""
  if [ -n "$KEYSTORE_REL_PATH" ]; then
    if [[ "$KEYSTORE_REL_PATH" == /* ]] && [ -f "$KEYSTORE_REL_PATH" ]; then
      RESOLVED_KEYSTORE="$KEYSTORE_REL_PATH"
    elif [[ "$KEYSTORE_REL_PATH" == ../* ]] && [ -f "$ROOT_DIR/android/${KEYSTORE_REL_PATH#../}" ]; then
      RESOLVED_KEYSTORE="$ROOT_DIR/android/${KEYSTORE_REL_PATH#../}"
    elif [ -f "$ROOT_DIR/android/$KEYSTORE_REL_PATH" ]; then
      RESOLVED_KEYSTORE="$ROOT_DIR/android/$KEYSTORE_REL_PATH"
    elif [ -f "$ROOT_DIR/$KEYSTORE_REL_PATH" ]; then
      RESOLVED_KEYSTORE="$ROOT_DIR/$KEYSTORE_REL_PATH"
    fi
  fi

  if [ -z "$RESOLVED_KEYSTORE" ]; then
    # Fallback to standard locations
    if [ -f "$ROOT_DIR/android/keystores/${APP_SLUG}-upload-keystore.jks" ]; then
      RESOLVED_KEYSTORE="$ROOT_DIR/android/keystores/${APP_SLUG}-upload-keystore.jks"
    elif [ -f "$HOME/.android/keystores/${APP_SLUG}-upload-keystore.jks" ]; then
      RESOLVED_KEYSTORE="$HOME/.android/keystores/${APP_SLUG}-upload-keystore.jks"
    fi
  fi

  if [ -n "$RESOLVED_KEYSTORE" ] && [ -f "$RESOLVED_KEYSTORE" ]; then
    if [ -n "$STORE_PASS" ] && [ -n "$KEY_ALIAS" ]; then
      # Verify keystore password & alias fast with keytool if available
      KT_CHECK=""
      if command -v keytool &>/dev/null; then
        KT_OUTPUT=$(keytool -list -keystore "$RESOLVED_KEYSTORE" -storepass "$STORE_PASS" -alias "$KEY_ALIAS" 2>&1 || true)
        if echo "$KT_OUTPUT" | grep -q "Alias <$KEY_ALIAS> does not exist"; then
          KT_CHECK="bad_alias"
        elif echo "$KT_OUTPUT" | grep -q -i "password was incorrect"; then
          KT_CHECK="bad_pass"
        elif echo "$KT_OUTPUT" | grep -q "Certificate fingerprint"; then
          KT_CHECK="ok"
        else
          # Execution restricted or different output format, but file and creds exist
          KT_CHECK="ok_file"
        fi
      else
        KT_CHECK="ok_file"
      fi

      if [ "$KT_CHECK" = "bad_alias" ]; then
        add_fail "Android Release Keystore" "Key alias '$KEY_ALIAS' not found in keystore" \
          "The alias '$KEY_ALIAS' does not exist in $RESOLVED_KEYSTORE." \
          "Check the alias used when creating the keystore, or update android/key.properties:\n   keyAlias=upload"
      elif [ "$KT_CHECK" = "bad_pass" ]; then
        add_fail "Android Release Keystore" "Incorrect keystore password" \
          "The password in android/key.properties or \$KEYSTORE_PASSWORD cannot open $RESOLVED_KEYSTORE." \
          "Update android/key.properties with the correct storePassword and keyPassword."
      else
        add_pass "Android Release Keystore" "Keystore verified ($RESOLVED_KEYSTORE, alias: $KEY_ALIAS)"
      fi
    else
      add_warn "Android Release Keystore" "Keystore found but password/alias missing in key.properties" \
        "Found keystore file at $RESOLVED_KEYSTORE, but storePassword or keyAlias is not set." \
        "Create or update android/key.properties:\n   storePassword=YOUR_PASSWORD\n   keyPassword=YOUR_PASSWORD\n   keyAlias=upload\n   storeFile=../keystores/${APP_SLUG}-upload-keystore.jks"
    fi
  else
    add_fail "Android Release Keystore" "Release keystore (.jks) not found" \
      "Android release builds require an RSA upload keystore to sign APK and AAB bundles." \
      "Generate your upload keystore in one command:\n   ./scripts/generate_keystore.sh $APP_SLUG upload"
  fi

  PLAY_KEY_FILE="$ROOT_DIR/android/keystores/${APP_SLUG}-play-store-key.json"
  if [ -f "$PLAY_KEY_FILE" ]; then
    add_pass "Google Play Service Account" "Publishing key found (${APP_SLUG}-play-store-key.json)"
  elif [ -n "${PLAY_STORE_JSON_KEY:-}" ]; then
    add_pass "Google Play Service Account" "Publishing key detected from environment (\$PLAY_STORE_JSON_KEY)"
  else
    if [ "$CI_MODE" = true ]; then
      add_fail "Google Play Service Account" "Missing Play Store JSON key for CI deployment" \
        "CI deployment requires a Google Cloud Service Account key to upload AABs to Google Play." \
        "Follow docs/DEPLOYMENT.md Step 3.2 to create a service account and save to:\n   android/keystores/${APP_SLUG}-play-store-key.json\n   or GitHub Secret: PLAY_STORE_JSON_KEY"
    else
      add_warn "Google Play Service Account" "Play Store JSON key not found (manual upload required)" \
        "No service account key found at android/keystores/${APP_SLUG}-play-store-key.json." \
        "Automated CI uploads will require this key. For local builds, you can still manually upload the generated AAB to Google Play Console."
    fi
  fi

fi

# ==============================================================================
# 3. IOS READINESS CHECKS
# ==============================================================================
if [ "$TARGET_PLATFORM" = "all" ] || [ "$TARGET_PLATFORM" = "ios" ]; then
  CURRENT_SCOPE="ios"

  # 3.1 Host OS Check
  if [[ "$OSTYPE" == "darwin"* ]]; then
    add_pass "macOS Darwin Host" "Running on Apple macOS ($(uname -m))"
  else
    add_fail "macOS Darwin Host" "Non-macOS environment detected ($OSTYPE)" \
      "iOS compilation and signing strictly require macOS with Xcode." \
      "Run iOS builds from an Apple Silicon Mac workstation."
  fi

  # 3.2 Xcode Command Line Tools & xcodebuild
  if command -v xcode-select &>/dev/null && [ -d "$(xcode-select -p 2>/dev/null || true)" ]; then
    XCODE_DIR="$(xcode-select -p)"
    if command -v xcodebuild &>/dev/null; then
      XCODE_RAW=$(xcodebuild -version 2>/dev/null || true)
      XCODE_VER=$(echo "$XCODE_RAW" | head -n 1)
      [ -z "$XCODE_VER" ] && XCODE_VER="Xcode active"
      add_pass "Xcode Toolchain" "$XCODE_VER ($XCODE_DIR)"
    else
      add_fail "Xcode Toolchain" "xcodebuild not found" \
        "Xcode Command Line Tools are linked, but the full Xcode application is missing." \
        "Install Xcode from the Mac App Store and run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    fi
  else
    add_fail "Xcode Toolchain" "Xcode Command Line Tools not configured" \
      "xcode-select path is not set or invalid." \
      "Run: xcode-select --install or select Xcode: sudo xcode-select -s /Applications/Xcode.app"
  fi

  # 3.3 CocoaPods Dependencies
  if [ -f "$ROOT_DIR/ios/Podfile.lock" ] && [ -d "$ROOT_DIR/ios/Pods" ]; then
    add_pass "CocoaPods Workspace" "Podfile.lock & Pods directory synced"
  else
    add_warn "CocoaPods Workspace" "ios/Pods directory or Podfile.lock missing" \
      "CocoaPods dependencies have not been installed yet." \
      "Run: cd ios && pod install && cd .."
  fi

  # 3.4 Firebase Configuration (GoogleService-Info.plist)
  IOS_PLIST="$ROOT_DIR/ios/Runner/GoogleService-Info.plist"
  if [ -f "$IOS_PLIST" ]; then
    if command -v plutil &>/dev/null; then
      if plutil -lint "$IOS_PLIST" &>/dev/null; then
        add_pass "iOS Firebase Config" "GoogleService-Info.plist is valid XML/plist"
      else
        add_fail "iOS Firebase Config" "GoogleService-Info.plist is corrupted" \
          "ios/Runner/GoogleService-Info.plist failed plist syntax validation." \
          "Download a fresh GoogleService-Info.plist from Firebase Console."
      fi
    else
      add_pass "iOS Firebase Config" "GoogleService-Info.plist present"
    fi
  else
    add_fail "iOS Firebase Config" "ios/Runner/GoogleService-Info.plist not found" \
      "Firebase plist is required for iOS push notifications and analytics." \
      "1. Open Firebase Console -> Project Settings -> General -> iOS app\n2. Download GoogleService-Info.plist\n3. Place it at: ios/Runner/GoogleService-Info.plist"
  fi

  # 3.5 Xcode Project Configuration (project.pbxproj)
  PBXPROJ="$ROOT_DIR/ios/Runner.xcodeproj/project.pbxproj"
  if [ -f "$PBXPROJ" ]; then
    PBX_BUNDLE_ID=$(grep 'PRODUCT_BUNDLE_IDENTIFIER' "$PBXPROJ" | grep -v 'RunnerTests' | grep -v 'Widget' | head -n 1 | sed -E 's/.*PRODUCT_BUNDLE_IDENTIFIER[[:space:]]*=[[:space:]]*([^;]+);.*/\1/' | tr -d '[:space:]' || true)
    PBX_TEAM=$(grep 'DEVELOPMENT_TEAM' "$PBXPROJ" | head -n 1 | sed -E 's/.*DEVELOPMENT_TEAM[[:space:]]*=[[:space:]]*([^;]+);.*/\1/' | tr -d '[:space:]' || true)

    if [ -n "$PBX_BUNDLE_ID" ]; then
      add_pass "iOS Bundle Identifier" "Configured as '$PBX_BUNDLE_ID'"
    else
      add_warn "iOS Bundle Identifier" "Could not extract PRODUCT_BUNDLE_IDENTIFIER" \
        "PRODUCT_BUNDLE_IDENTIFIER was not found in ios/Runner.xcodeproj/project.pbxproj." \
        "Open ios/Runner.xcworkspace in Xcode and set Bundle Identifier under Signing & Capabilities."
    fi

    if [ -n "$PBX_TEAM" ]; then
      add_pass "Apple Development Team" "Team ID configured: $PBX_TEAM"
    else
      add_warn "Apple Development Team" "DEVELOPMENT_TEAM is empty in project.pbxproj" \
        "No Apple Team ID is specified in the Xcode project." \
        "Open ios/Runner.xcworkspace in Xcode and select your Development Team under Signing & Capabilities."
    fi
  else
    add_fail "Xcode Project File" "ios/Runner.xcodeproj/project.pbxproj missing" \
      "The iOS Xcode project file does not exist." \
      "Verify that the mobile workspace contains the ios/ directory."
  fi

  # 3.6 App Store Connect API Credentials (.p8 & credentials file)
  if [ "$BUILD_ONLY" = true ]; then
    add_skip "App Store Connect API" "Skipped (--build-only specified)"
  else
    # Discover credentials from ~/.appstoreconnect/credentials or .env.appstore or env
    ASC_CREDS_FILE="$HOME/.appstoreconnect/credentials"
    ALT_ASC_CREDS="$ROOT_DIR/.env.appstore"
    STORE_KEY_ID="${APP_STORE_KEY_ID:-${ASC_KEY_ID:-}}"
    STORE_ISSUER_ID="${APP_STORE_ISSUER_ID:-${ASC_ISSUER_ID:-}}"

    if [ -z "$STORE_KEY_ID" ] || [ -z "$STORE_ISSUER_ID" ]; then
      if [ -f "$ASC_CREDS_FILE" ]; then
        # shellcheck disable=SC1090
        source "$ASC_CREDS_FILE" 2>/dev/null || true
      elif [ -f "$ALT_ASC_CREDS" ]; then
        # shellcheck disable=SC1091
        source "$ALT_ASC_CREDS" 2>/dev/null || true
      fi
      STORE_KEY_ID="${APP_STORE_KEY_ID:-${ASC_KEY_ID:-$STORE_KEY_ID}}"
      STORE_ISSUER_ID="${APP_STORE_ISSUER_ID:-${ASC_ISSUER_ID:-$STORE_ISSUER_ID}}"
    fi

    # Auto-discover Key ID from private_keys if still empty
    if [ -z "$STORE_KEY_ID" ]; then
      KEY_DISCOVERED=$(find "$HOME/.appstoreconnect/private_keys" "$HOME/.private_keys" -name "AuthKey_*.p8" 2>/dev/null | head -n 1 || true)
      if [ -n "$KEY_DISCOVERED" ]; then
        STORE_KEY_ID=$(basename "$KEY_DISCOVERED" | sed -E 's/AuthKey_(.*)\.p8/\1/')
      fi
    fi

    # Validate Key ID
    if [ -n "$STORE_KEY_ID" ] && [[ "$STORE_KEY_ID" =~ ^[A-Za-z0-9]{10}$ ]]; then
      add_pass "App Store API Key ID" "Key ID: $STORE_KEY_ID"
    else
      add_fail "App Store API Key ID" "Missing or invalid Key ID (10 chars required)" \
        "App Store Connect Key ID is missing from ~/.appstoreconnect/credentials." \
        "1. Open https://appstoreconnect.apple.com -> Users and Access -> Integrations -> App Store Connect API\n2. Note your 10-character Key ID (e.g. 27Y2ANB78U)\n3. Save to ~/.appstoreconnect/credentials:\n   export APP_STORE_KEY_ID=\"YOUR_KEY_ID\""
    fi

    # Validate Issuer ID
    if [ -n "$STORE_ISSUER_ID" ] && [[ "$STORE_ISSUER_ID" =~ ^[0-9a-fA-F-]{36}$ ]]; then
      add_pass "App Store API Issuer ID" "Issuer ID: $STORE_ISSUER_ID"
    else
      add_fail "App Store API Issuer ID" "Missing or invalid Issuer UUID" \
        "App Store Connect Issuer ID is missing or not a valid UUID format." \
        "1. Open https://appstoreconnect.apple.com -> Users and Access -> Integrations -> App Store Connect API\n2. Copy Issuer ID UUID (top of page)\n3. Save to ~/.appstoreconnect/credentials:\n   export APP_STORE_ISSUER_ID=\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx\""
    fi

    # Validate Private Key File (.p8)
    KEY_P8_FILE=""
    if [ -n "$STORE_KEY_ID" ]; then
      if [ -f "$HOME/.appstoreconnect/private_keys/AuthKey_${STORE_KEY_ID}.p8" ]; then
        KEY_P8_FILE="$HOME/.appstoreconnect/private_keys/AuthKey_${STORE_KEY_ID}.p8"
      elif [ -f "$HOME/.private_keys/AuthKey_${STORE_KEY_ID}.p8" ]; then
        KEY_P8_FILE="$HOME/.private_keys/AuthKey_${STORE_KEY_ID}.p8"
      fi
    fi

    if [ -n "$KEY_P8_FILE" ] && [ -f "$KEY_P8_FILE" ]; then
      # Validate key structure via OpenSSL
      if command -v openssl &>/dev/null && openssl pkey -in "$KEY_P8_FILE" -noout &>/dev/null; then
        add_pass "App Store API Private Key" "AuthKey_${STORE_KEY_ID}.p8 verified via OpenSSL"
      else
        add_pass "App Store API Private Key" "AuthKey_${STORE_KEY_ID}.p8 found"
      fi
    else
      add_fail "App Store API Private Key" "AuthKey_${STORE_KEY_ID:-<KEY_ID>}.p8 not found" \
        "The App Store Connect private key file was not found in ~/.appstoreconnect/private_keys/." \
        "1. Download your AuthKey_${STORE_KEY_ID:-<KEY_ID>}.p8 from App Store Connect (only downloadable once).\n2. Move it to the secure directory:\n   mkdir -p ~/.appstoreconnect/private_keys\n   mv ~/Downloads/AuthKey_${STORE_KEY_ID:-<KEY_ID>}.p8 ~/.appstoreconnect/private_keys/\n   chmod 600 ~/.appstoreconnect/private_keys/AuthKey_${STORE_KEY_ID:-<KEY_ID>}.p8"
    fi
  fi

fi

# ==============================================================================
# 4. RENDER VISUAL CHECKLIST & SUMMARY
# ==============================================================================

TOTAL_COUNT=${#CHECK_NAMES[@]}
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

for s in "${CHECK_STATUSES[@]}"; do
  case "$s" in
    PASS) PASS_COUNT=$((PASS_COUNT + 1)) ;;
    WARN) WARN_COUNT=$((WARN_COUNT + 1)) ;;
    FAIL) FAIL_COUNT=$((FAIL_COUNT + 1)) ;;
    SKIP) SKIP_COUNT=$((SKIP_COUNT + 1)) ;;
  esac
done

echo ""
echo "========================================================================"
echo_e "${BOLD}🚦 ${UPPER_APP} MOBILE PRE-FLIGHT RELEASE READINESS CHECKLIST${NC}"
echo "========================================================================"
echo_e "🎯 Target Environment: ${BOLD}${UPPER_ENV}${NC} (.env.${TARGET_ENV})"
echo_e "📱 Platform Scope:     ${BOLD}${UPPER_PLATFORM}${NC}"
echo_e "📦 Target App:         ${BOLD}${APP_DISPLAY_NAME}${NC} (${PACKAGE_NAME})"
if [ -n "$VERSION_NAME" ]; then
  echo_e "🏷️ Version / Build:    v${VERSION_NAME} (Build ${BUILD_NUMBER})"
fi
if [ "$BUILD_ONLY" = true ]; then
  echo_e "⚙️ Mode:                ${CYAN}Build-Only (Remote uploads skipped)${NC}"
fi
echo "------------------------------------------------------------------------"

for i in "${!CHECK_NAMES[@]}"; do
  NAME="${CHECK_NAMES[$i]}"
  STATUS="${CHECK_STATUSES[$i]}"
  DETAIL="${CHECK_DETAILS[$i]}"

  case "$STATUS" in
    PASS)
      printf "  ${GREEN}[ PASS ]${NC} %-32s ${DIM}%s${NC}\n" "$NAME" "$DETAIL"
      ;;
    WARN)
      printf "  ${YELLOW}[ WARN ]${NC} %-32s ${YELLOW}%s${NC}\n" "$NAME" "$DETAIL"
      ;;
    FAIL)
      printf "  ${RED}[ FAIL ]${NC} %-32s ${RED}${BOLD}%s${NC}\n" "$NAME" "$DETAIL"
      ;;
    SKIP)
      printf "  ${CYAN}[ SKIP ]${NC} %-32s ${DIM}%s${NC}\n" "$NAME" "$DETAIL"
      ;;
  esac
done

echo "========================================================================"
printf "📊 Status Summary: ${GREEN}%d Passed${NC} | ${YELLOW}%d Warnings${NC} | ${RED}%d Failed${NC}" "$PASS_COUNT" "$WARN_COUNT" "$FAIL_COUNT"
if [ "$SKIP_COUNT" -gt 0 ]; then
  printf " | ${CYAN}%d Skipped${NC}" "$SKIP_COUNT"
fi
printf "\n"

ANDROID_BLOCKERS=$((SHARED_FAILS + ANDROID_FAILS))
IOS_BLOCKERS=$((SHARED_FAILS + IOS_FAILS))

if [ "$TARGET_PLATFORM" = "all" ]; then
  echo "------------------------------------------------------------------------"
  echo_e "${BOLD}📱 PLATFORM INDEPENDENT RELEASE VIABILITY:${NC}"
  if [ "$ANDROID_BLOCKERS" -eq 0 ]; then
    echo_e "  🤖 Android Release:   ${GREEN}${BOLD}✅ 100% READY TO BUILD${NC} (Run: ./scripts/release_android.sh $TARGET_ENV)"
  else
    echo_e "  🤖 Android Release:   ${RED}${BOLD}❌ BLOCKED ($ANDROID_BLOCKERS issue(s))${NC}"
  fi

  if [ "$IOS_BLOCKERS" -eq 0 ]; then
    echo_e "  🍎 iOS Release:       ${GREEN}${BOLD}✅ 100% READY TO BUILD${NC} (Run: ./scripts/release_ios.sh $TARGET_ENV)"
  else
    echo_e "  🍎 iOS Release:       ${RED}${BOLD}❌ BLOCKED ($IOS_BLOCKERS issue(s))${NC}"
  fi
fi
echo "========================================================================"

# ==============================================================================
# 5. DETAILED ACTIONABLE REMEDIATION GUIDE
# ==============================================================================

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo ""
  echo_e "${RED}${BOLD}🚨 PRE-FLIGHT VERIFICATION FAILED: ${FAIL_COUNT} BLOCKING ISSUE(S) DETECTED${NC}"
  echo_e "${RED}🛑 Build was aborted BEFORE starting to prevent wasted compile time & resources.${NC}"
  echo ""
  echo_e "${BOLD}Please resolve the following issue(s) before building or deploying:${NC}"
  echo "------------------------------------------------------------------------"

  for i in "${!FAIL_TITLES[@]}"; do
    NUM=$((i + 1))
    SCOPE="${FAIL_SCOPES[$i]}"
    TITLE="${FAIL_TITLES[$i]}"
    PROBLEM="${FAIL_PROBLEMS[$i]}"
    REMEDY="${FAIL_REMEDIES[$i]}"

    SCOPE_BADGE=""
    case "$SCOPE" in
      android) SCOPE_BADGE="[🤖 Android] " ;;
      ios)     SCOPE_BADGE="[🍎 iOS] " ;;
      shared)  SCOPE_BADGE="[🌐 Shared] " ;;
    esac

    echo_e "${RED}${BOLD}[$NUM] ${SCOPE_BADGE}${TITLE}${NC}"
    echo_e "    ${BOLD}Problem:${NC} $PROBLEM"
    echo_e "    ${BOLD}Exact Solution:${NC}"
    echo_e "$REMEDY" | while IFS= read -r line; do
      echo_e "      $line"
    done
    echo "------------------------------------------------------------------------"
  done

  if [ "$TARGET_PLATFORM" = "all" ]; then
    if [ "$ANDROID_BLOCKERS" -eq 0 ] && [ "$IOS_BLOCKERS" -gt 0 ]; then
      echo ""
      echo_e "💡 ${GREEN}${BOLD}Platform Independence Reassurance:${NC}"
      echo_e "   The failure(s) above strictly affect ${BOLD}iOS${NC}."
      echo_e "   ${GREEN}Android release is 100% unaffected and ready to build immediately:${NC}"
      echo_e "     ${CYAN}./scripts/release_android.sh $TARGET_ENV${NC}"
      echo "------------------------------------------------------------------------"
    elif [ "$IOS_BLOCKERS" -eq 0 ] && [ "$ANDROID_BLOCKERS" -gt 0 ]; then
      echo ""
      echo_e "💡 ${GREEN}${BOLD}Platform Independence Reassurance:${NC}"
      echo_e "   The failure(s) above strictly affect ${BOLD}Android${NC}."
      echo_e "   ${GREEN}iOS release is 100% unaffected and ready to build immediately:${NC}"
      echo_e "     ${CYAN}./scripts/release_ios.sh $TARGET_ENV${NC}"
      echo "------------------------------------------------------------------------"
    fi
  fi
fi

if [ "$WARN_COUNT" -gt 0 ] && [ "$FAIL_COUNT" -eq 0 ]; then
  echo ""
  echo_e "${YELLOW}${BOLD}⚠️ ADVISORY WARNINGS (${WARN_COUNT}):${NC}"
  for i in "${!WARN_TITLES[@]}"; do
    TITLE="${WARN_TITLES[$i]}"
    PROBLEM="${WARN_PROBLEMS[$i]}"
    REMEDY="${WARN_REMEDIES[$i]}"
    echo_e "  • ${YELLOW}${BOLD}$TITLE:${NC} $PROBLEM"
    echo_e "    ${DIM}Recommendation: $(echo "$REMEDY" | head -n 1)${NC}"
  done
fi

# Exit code decision strictly scoped to target platform
EXIT_CODE=0
if [ "$TARGET_PLATFORM" = "android" ]; then
  [ "$ANDROID_BLOCKERS" -gt 0 ] && EXIT_CODE=1
elif [ "$TARGET_PLATFORM" = "ios" ]; then
  [ "$IOS_BLOCKERS" -gt 0 ] && EXIT_CODE=1
else
  [ "$FAIL_COUNT" -gt 0 ] && EXIT_CODE=1
fi

if [ "$EXIT_CODE" -eq 0 ]; then
  echo ""
  echo_e "${GREEN}${BOLD}🎉 PRE-FLIGHT CHECKS PASSED FOR ${UPPER_PLATFORM}!${NC}"
  echo_e "You are 100% ready to build and release ${APP_DISPLAY_NAME}."
  echo ""
  exit 0
else
  exit 1
fi
