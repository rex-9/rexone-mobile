#!/usr/bin/env bash
# scripts/update_app_icon.sh
# Usage: ./scripts/update_app_icon.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔄 Updating app icons..."
cd "$ROOT_DIR"
dart run flutter_launcher_icons:main
echo "✅ App icon updated successfully!"