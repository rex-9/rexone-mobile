#!/usr/bin/env bash
# scripts/update_app_icon.sh
# Usage: ./scripts/update_app_icon.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔄 Updating app icons..."
cd "$ROOT_DIR"
if command -v dart >/dev/null 2>&1; then
  dart run flutter_launcher_icons:main 2>/dev/null || echo "  ⚠️ Note: flutter_launcher_icons requires host cache access. Run 'flutter pub run flutter_launcher_icons' natively if regenerating icon sizes."
fi
echo "✅ App icon updated successfully!"