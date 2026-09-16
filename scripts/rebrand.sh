#!/bin/bash
# scripts/rebrand.sh
# Unified Mobile Rebranding Script
# Usage: ./scripts/rebrand.sh "New App Name" "com.company.newapp" [optional_logo_path]

set -e

APP_NAME="$1"
PACKAGE_NAME="$2"
LOGO_PATH="$3"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -z "$APP_NAME" ]; then
  echo "📱 RexOne Mobile Rebrand Script"
  echo "----------------------------------------"
  echo "💡 TIP: For full cross-platform sync (Web, Mobile, Core), run:"
  echo "   cd ../rexone-core && ./scripts/rebrand.sh"
  echo "----------------------------------------"
  echo "Usage: ./scripts/rebrand.sh \"New App Name\" \"com.company.newapp\" [path/to/logo.png]"
  exit 1
fi

echo "🚀 Starting Mobile Rebranding for: $APP_NAME"
echo "💡 (Note: For ecosystem-wide rebrand, run from rexone-core: ./scripts/rebrand.sh)"

# 1. Update App Name
"$SCRIPT_DIR/update_app_name.sh" "$APP_NAME"

# 2. Update Package Name / Bundle ID if provided
if [ -n "$PACKAGE_NAME" ]; then
  "$SCRIPT_DIR/update_package_name.sh" "$PACKAGE_NAME"
fi

# 3. Update Logo / Icon if provided
if [ -n "$LOGO_PATH" ] && [ -f "$LOGO_PATH" ]; then
  echo "🖼️ Updating App Launcher Icon from: $LOGO_PATH..."
  cp "$LOGO_PATH" "$ROOT_DIR/assets/brand/logo.png"
  "$SCRIPT_DIR/update_app_icon.sh"
fi

echo "✨ Mobile rebranding complete! ✨"

