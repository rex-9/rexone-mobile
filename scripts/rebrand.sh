#!/usr/bin/env bash
# scripts/rebrand.sh
# Unified Mobile Rebranding Script
# Usage: ./scripts/rebrand.sh "New App Name" "com.company.newapp" [optional_logo_path] [optional_brand_name]

set -euo pipefail

APP_NAME="${1:-}"
PACKAGE_NAME="${2:-}"
LOGO_PATH="${3:-}"
BRAND_NAME="${4:-$APP_NAME}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

sedi() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

if [ -z "$APP_NAME" ]; then
  echo "📱 RexOne Mobile Rebrand Script"
  echo "----------------------------------------"
  echo "💡 TIP: For full cross-platform sync (Web, Mobile, Core), run:"
  echo "   cd ../rexone-core && ./scripts/rebrand.sh"
  echo "----------------------------------------"
  echo "Usage: ./scripts/rebrand.sh \"New App Name\" \"com.company.newapp\" [path/to/logo.png] [BrandName]"
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

# 4. Synchronize user-facing brand name in translations
if [ -n "$BRAND_NAME" ] && [ -f "$ROOT_DIR/lib/locales/app_translations.dart" ]; then
  sedi -E "s/Welcome to [^'!]+/Welcome to $BRAND_NAME/g" "$ROOT_DIR/lib/locales/app_translations.dart"
  echo "  ✅ AppTranslations: Synchronized brand display name ($BRAND_NAME)"
fi

echo "✨ Mobile rebranding complete! ✨"
