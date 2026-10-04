#!/usr/bin/env bash
# scripts/copy_keystore_base64.sh
# Quickly encodes an existing Android upload keystore to Base64 and copies it to macOS clipboard
# Usage: ./scripts/copy_keystore_base64.sh [app_name]
# Example: ./scripts/copy_keystore_base64.sh rexone

set -euo pipefail

APP_NAME="${1:-rexone}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

CANDIDATES=(
  "$ROOT_DIR/android/keystores/${APP_NAME}-upload-keystore.jks"
  "$ROOT_DIR/keystores/${APP_NAME}-upload-keystore.jks"
  "$HOME/.android/keystores/${APP_NAME}-upload-keystore.jks"
  "$ROOT_DIR/android/app/upload-keystore.jks"
)

KEYSTORE_PATH=""
for path in "${CANDIDATES[@]}"; do
  if [ -f "$path" ]; then
    KEYSTORE_PATH="$path"
    break
  fi
done

if [ -z "$KEYSTORE_PATH" ]; then
  echo "❌ Error: Could not locate keystore for '$APP_NAME'."
  echo "   Checked locations:"
  for path in "${CANDIDATES[@]}"; do
    echo "     • $path"
  done
  echo ""
  echo "   Run ./scripts/generate_keystore.sh to create one first."
  exit 1
fi

BASE64_KEY=$(base64 < "$KEYSTORE_PATH" | tr -d '\n')

if [[ "$OSTYPE" == "darwin"* ]] && command -v pbcopy &> /dev/null; then
  echo "$BASE64_KEY" | pbcopy
  echo "============================================================"
  echo "📋 SUCCESS: Keystore Base64 copied directly to your clipboard!"
  echo "============================================================"
  echo "📁 Source Keystore: $KEYSTORE_PATH"
  echo "🔑 Target Secret:   ANDROID_KEYSTORE_BASE64"
  echo "👉 Paste it now at: https://github.com/rex-9/rexone_mobile/settings/secrets/actions"
  echo "============================================================"
else
  echo "$BASE64_KEY"
fi
