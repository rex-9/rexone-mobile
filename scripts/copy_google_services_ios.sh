#!/usr/bin/env bash
# scripts/copy_google_services_ios.sh
# Copies ios/Runner/GoogleService-Info.plist to macOS clipboard for GitHub Secrets
# Usage: ./scripts/copy_google_services_ios.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

PLIST_PATH="$ROOT_DIR/ios/Runner/GoogleService-Info.plist"

if [ ! -f "$PLIST_PATH" ]; then
  echo "❌ Error: Could not locate $PLIST_PATH"
  exit 1
fi

if [[ "$OSTYPE" == "darwin"* ]] && command -v pbcopy &> /dev/null; then
  pbcopy < "$PLIST_PATH"
  echo "============================================================"
  echo "📋 SUCCESS: iOS Google Service Info plist copied to clipboard!"
  echo "============================================================"
  echo "🍎 Platform:        iOS"
  echo "📁 Source File:     $PLIST_PATH"
  echo "🔑 Target Secret:   IOS_GOOGLE_SERVICES_PLIST"
  echo "👉 Paste it now at: https://github.com/rex-9/rexone_mobile/settings/secrets/actions"
  echo "============================================================"
else
  cat "$PLIST_PATH"
fi
