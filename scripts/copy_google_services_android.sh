#!/usr/bin/env bash
# scripts/copy_google_services_android.sh
# Copies android/app/google-services.json to macOS clipboard for GitHub Secrets
# Usage: ./scripts/copy_google_services_android.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

JSON_PATH="$ROOT_DIR/android/app/google-services.json"

if [ ! -f "$JSON_PATH" ]; then
  echo "❌ Error: Could not locate $JSON_PATH"
  exit 1
fi

if [[ "$OSTYPE" == "darwin"* ]] && command -v pbcopy &> /dev/null; then
  pbcopy < "$JSON_PATH"
  echo "============================================================"
  echo "📋 SUCCESS: Android Google Services JSON copied to clipboard!"
  echo "============================================================"
  echo "📱 Platform:        Android"
  echo "📁 Source File:     $JSON_PATH"
  echo "🔑 Target Secret:   ANDROID_GOOGLE_SERVICES_JSON"
  echo "👉 Paste it now at: https://github.com/rex-9/rexone_mobile/settings/secrets/actions"
  echo "============================================================"
else
  cat "$JSON_PATH"
fi
