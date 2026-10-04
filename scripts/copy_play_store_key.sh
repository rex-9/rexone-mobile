#!/usr/bin/env bash
# scripts/copy_play_store_key.sh
# Copies the Google Play Developer API Service Account JSON key to macOS clipboard
# Usage: ./scripts/copy_play_store_key.sh [app_name]
# Example: ./scripts/copy_play_store_key.sh rexone

set -euo pipefail

APP_NAME="${1:-rexone}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

CANDIDATES=(
  "$ROOT_DIR/android/keystores/${APP_NAME}-play-store-key.json"
  "$ROOT_DIR/android/keystores/rexone-play-store-key.json"
  "$ROOT_DIR/android/keystores/play-store-key.json"
  "$ROOT_DIR/keystores/${APP_NAME}-play-store-key.json"
  "$ROOT_DIR/keystores/rexone-play-store-key.json"
  "$ROOT_DIR/../keystores/${APP_NAME}-play-store-key.json"
  "$ROOT_DIR/../keystores/rexone-play-store-key.json"
)

JSON_KEY_PATH=""
for path in "${CANDIDATES[@]}"; do
  if [ -f "$path" ]; then
    JSON_KEY_PATH="$path"
    break
  fi
done

if [ -z "$JSON_KEY_PATH" ]; then
  echo "❌ Error: Could not locate Play Store JSON key for '$APP_NAME'."
  echo "   Checked locations:"
  for path in "${CANDIDATES[@]}"; do
    echo "     • $path"
  done
  echo ""
  echo "   Please place your downloaded Google Cloud Service Account JSON file in:"
  echo "     $ROOT_DIR/keystores/rexone-play-store-key.json"
  exit 1
fi

if [[ "$OSTYPE" == "darwin"* ]] && command -v pbcopy &> /dev/null; then
  pbcopy < "$JSON_KEY_PATH"
  echo "============================================================"
  echo "📋 SUCCESS: Google Play Service Account JSON copied to clipboard!"
  echo "============================================================"
  echo "📁 Source Key:      $JSON_KEY_PATH"
  echo "🔑 Target Secret:   PLAY_STORE_JSON_KEY"
  echo "👉 Paste it now at: https://github.com/rex-9/rexone_mobile/settings/secrets/actions"
  echo "============================================================"
else
  cat "$JSON_KEY_PATH"
fi
