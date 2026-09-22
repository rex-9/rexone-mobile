#!/usr/bin/env bash

# ==============================================================================
# RexOne Mobile — E2E Test Runner with Clean Summary Reporter
#
# Usage:
#   ./scripts/test.sh [flow|file] [-d device] [options]
#
# Examples:
#   ./scripts/test.sh                                  # Run all auth flows
#   ./scripts/test.sh sign-in                          # Run Sign In flow
#   ./scripts/test.sh sign-up                          # Run Sign Up flow
#   ./scripts/test.sh passcode                         # Run Passcode flow
#   ./scripts/test.sh password-reset                   # Run Password Reset flow
#   ./scripts/test.sh sign-out                         # Run Sign Out flow
#   ./scripts/test.sh -d "emulator-5554"               # Run on specific device
#   ./scripts/test.sh sign-in -d "emulator-5554"       # Specific flow on device
#   ./scripts/test.sh integration_test/auth/sign_in_test.dart
# ==============================================================================

# Add Dart global pub cache to PATH if present
export PATH="$PATH:$HOME/.pub-cache/bin:${PUB_CACHE:-$HOME/.pub-cache}/bin"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

TARGET=""
DEVICE=""
USE_PATROL=false
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      echo "RexOne Mobile — E2E Test Runner"
      echo ""
      echo "Usage: ./scripts/test.sh [flow|file] [-d device] [--flutter|--patrol]"
      echo ""
      echo "Available Flows:"
      echo "  all             Run all E2E test suites (6 suites, 7 tests)"
      echo "  sign-in         Sign In with email & passcode"
      echo "  sign-up         Full registration flow & validation"
      echo "  passcode        Passcode matching, mismatch rejection, retries"
      echo "  password-reset  Forgot passcode request and verification"
      echo "  sso             Google SSO authentication"
      echo "  sign-out        Sign out & session termination"
      echo ""
      echo "Options:"
      echo "  -d, --device    Target device (e.g. 'emulator-5554', 'iPhone 16 Pro', 'macos')"
      echo "  --flutter       Run via Flutter test runner (default, fast & reliable)"
      echo "  --patrol        Run via Patrol CLI runner"
      echo "  -v, --verbose   Verbose logging output"
      echo ""
      exit 0
      ;;
    -d|--device)
      DEVICE="$2"
      shift 2
      ;;
    --patrol)
      USE_PATROL=true
      shift
      ;;
    --flutter)
      USE_PATROL=false
      shift
      ;;
    -v|--verbose)
      EXTRA_ARGS+=("-v")
      shift
      ;;
    all)
      TARGET="all"
      shift
      ;;
    sign-in|signin|login)
      TARGET="integration_test/auth/sign_in_test.dart"
      shift
      ;;
    sign-up|signup|register)
      TARGET="integration_test/auth/sign_up_test.dart"
      shift
      ;;
    password|passcode|pin)
      TARGET="integration_test/auth/password_test.dart"
      shift
      ;;
    password-reset|reset-password|forgot|forgot-password|forgot-passcode)
      TARGET="integration_test/auth/password_reset_test.dart"
      shift
      ;;
    sso|google)
      TARGET="integration_test/auth/sso_test.dart"
      shift
      ;;
    sign-out|signout|logout)
      TARGET="integration_test/auth/sign_out_test.dart"
      shift
      ;;
    *.dart|integration_test/*)
      TARGET="$1"
      shift
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

if [ -z "$TARGET" ]; then
  TARGET="all"
fi

# Auto-detect device if none specified
if [ -z "$DEVICE" ]; then
  RUNNING_EMU=$(flutter devices | grep -E "emulator-|iPhone|macOS" | head -n 1 | awk -F'•' '{print $2}' | xargs || true)
  if [ -n "$RUNNING_EMU" ]; then
    DEVICE="$RUNNING_EMU"
  fi
fi

# Dynamically resolve package name from pubspec.yaml or fallback
PACKAGE_NAME=$(grep -E '^\s*package_name:\s*' pubspec.yaml | head -n 1 | awk '{print $2}' || true)
PACKAGE_NAME="${PACKAGE_NAME:-com.rex9.rexone}"

if [ "$TARGET" = "all" ]; then
  TEST_FILES=(
    "integration_test/auth/sign_in_test.dart"
    "integration_test/auth/sign_up_test.dart"
    "integration_test/auth/password_test.dart"
    "integration_test/auth/password_reset_test.dart"
    "integration_test/auth/sign_out_test.dart"
    "integration_test/auth/sso_test.dart"
  )
else
  TEST_FILES=("$TARGET")
fi

echo "===================================================="
echo " 🌕 RexOne Mobile E2E Test Runner"
echo " Suites:  ${#TEST_FILES[@]}"
echo " Device:  ${DEVICE:-default}"
echo " Package: $PACKAGE_NAME"
echo "===================================================="

cleanup_test_data() {
  echo ""
  echo "🧹 Cleaning up test users from database..."
  docker exec dev-rexone-core-api bin/rails runner "User.where('email LIKE ? OR email LIKE ?', 'e2e-%', '%@rexone.test').destroy_all" 2>/dev/null || true
}

ensure_test_users() {
  echo "🌱 Ensuring prerequisite E2E test users exist in database..."
  docker exec dev-rexone-core-api bin/rails runner "
    just = User.find_or_initialize_by(email: 'just@admin.com')
    just.assign_attributes(name: 'Just Admin User', username: 'justadmin', password: '123456', password_confirmation: '123456')
    just.confirmed_at ||= Time.current
    just.save!
    admin_role = Iam::Role.find_by(name: IamConstants::Role::ADMIN) || Iam::Role.find_by(name: IamConstants::Role::USER)
    Iam::UserRole.find_or_create_by!(user: just, role: admin_role) if admin_role
  " 2>/dev/null || true
}

trap cleanup_test_data EXIT

# Pre-clean database and ensure test credentials exist
cleanup_test_data
ensure_test_users

PASSED_COUNT=0
FAILED_COUNT=0
RESULTS=()

TOTAL_START=$(date +%s)

for file in "${TEST_FILES[@]}"; do
  SUITE_NAME=$(basename "$file" .dart)
  echo ""
  echo "----------------------------------------------------"
  echo " ▶ Running Suite: $SUITE_NAME ($file)"
  echo "----------------------------------------------------"

  START_TIME=$(date +%s)

  # Pre-grant notification permissions to prevent system dialog interruption
  if [ -n "$DEVICE" ]; then
    adb -s "$DEVICE" shell pm grant "$PACKAGE_NAME" android.permission.POST_NOTIFICATIONS 2>/dev/null || true
  else
    adb shell pm grant "$PACKAGE_NAME" android.permission.POST_NOTIFICATIONS 2>/dev/null || true
  fi

  CMD=("flutter" "drive" "--driver=test_driver/integration_test.dart" "--target=$file")
  if [ -n "$DEVICE" ]; then
    CMD+=("-d" "$DEVICE")
  fi
  if [ ${#EXTRA_ARGS[@]} -gt 0 ]; then
    CMD+=("${EXTRA_ARGS[@]}")
  fi

  if "${CMD[@]}"; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    PASSED_COUNT=$((PASSED_COUNT + 1))
    RESULTS+=("✅ PASSED: $SUITE_NAME (${DURATION}s)")
    echo "✅ [PASS] $SUITE_NAME completed in ${DURATION}s"
  else
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    FAILED_COUNT=$((FAILED_COUNT + 1))
    RESULTS+=("❌ FAILED: $SUITE_NAME (${DURATION}s)")
    echo "❌ [FAIL] $SUITE_NAME failed in ${DURATION}s"
  fi
done

TOTAL_END=$(date +%s)
TOTAL_DURATION=$((TOTAL_END - TOTAL_START))

echo ""
echo "===================================================="
echo " 📊 E2E Test Execution Summary"
echo "===================================================="
for res in "${RESULTS[@]}"; do
  echo "  $res"
done
echo "----------------------------------------------------"
echo " Total Suites : ${#TEST_FILES[@]}"
echo " Passed       : $PASSED_COUNT"
echo " Failed       : $FAILED_COUNT"
echo " Duration     : ${TOTAL_DURATION}s"
echo "===================================================="

if [ "$FAILED_COUNT" -gt 0 ]; then
  exit 1
else
  exit 0
fi
