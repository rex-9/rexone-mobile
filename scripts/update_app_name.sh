#!/usr/bin/env bash
# scripts/update_app_name.sh
# Usage: ./scripts/update_app_name.sh "My New App Name"

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "❌ Error: App name required."
  echo "Usage: ./scripts/update_app_name.sh \"New App Name\""
  exit 1
fi

NEW_APP_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

sedi() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

echo "🔄 Updating App Name to: \"$NEW_APP_NAME\"..."

# 1. Android Manifest (android:label)
if [ -f "$ROOT_DIR/android/app/src/main/AndroidManifest.xml" ]; then
  android_label="$NEW_APP_NAME"
  if [ "$NEW_APP_NAME" = "RexOne" ] || [ "$NEW_APP_NAME" = "RexOne Mobile" ]; then
    android_label="rexone_mobile"
  fi
  sedi -E "s/android:label=\"[^\"]*\"/android:label=\"$android_label\"/g" "$ROOT_DIR/android/app/src/main/AndroidManifest.xml"
  echo "  ✅ Android: Updated android:label in AndroidManifest.xml"
fi

# 2. iOS Info.plist (CFBundleDisplayName & CFBundleName)
if [ -f "$ROOT_DIR/ios/Runner/Info.plist" ]; then
  cf_display_name="$NEW_APP_NAME"
  cf_bundle_name="$NEW_APP_NAME"
  if [ "$NEW_APP_NAME" = "RexOne" ] || [ "$NEW_APP_NAME" = "RexOne Mobile" ]; then
    cf_display_name="RexOne Mobile"
    cf_bundle_name="rexone_mobile"
  fi

  node -e "
    const fs = require('fs');
    const file = '$ROOT_DIR/ios/Runner/Info.plist';
    if (fs.existsSync(file)) {
      let c = fs.readFileSync(file, 'utf8');
      c = c.replace(/(<key>CFBundleDisplayName<\/key>\s*<string>)[^<]*(<\/string>)/, '\$1$cf_display_name\$2');
      c = c.replace(/(<key>CFBundleName<\/key>\s*(?:<!--[^\n]*-->\s*)?<string>)[^<]*(<\/string>)/, '\$1$cf_bundle_name\$2');
      fs.writeFileSync(file, c);
    }
  " 2>/dev/null || true

  echo "  ✅ iOS: Updated CFBundleDisplayName and CFBundleName in Info.plist"
fi

# 3. pubspec.yaml description & patrol app_name
if [ -f "$ROOT_DIR/pubspec.yaml" ]; then
  pub_desc="$NEW_APP_NAME # \$APP_NAME"
  patrol_app="$NEW_APP_NAME"
  if [ "$NEW_APP_NAME" = "RexOne" ] || [ "$NEW_APP_NAME" = "RexOne Mobile" ]; then
    pub_desc="RexOne Mobile App # \$APP_NAME"
    patrol_app="RexOne"
  fi
  sedi -E "s/^description: .*/description: $pub_desc/g" "$ROOT_DIR/pubspec.yaml"
  sedi -E "s/app_name:[[:space:]]*.*/app_name: $patrol_app/g" "$ROOT_DIR/pubspec.yaml"
  echo "  ✅ pubspec.yaml: Updated description and patrol app_name"
fi

# 4. Environment example file (Strict Law & Secret Isolation: never touch local gitignored .env files)
if [ -f "$ROOT_DIR/.env.example" ]; then
  env_app_name="$NEW_APP_NAME"
  if [ "$NEW_APP_NAME" = "RexOne" ] || [ "$NEW_APP_NAME" = "RexOne Mobile" ]; then
    env_app_name="RexOne"
  fi
  sedi -E "s/^APP_NAME=.*/APP_NAME=$env_app_name/g" "$ROOT_DIR/.env.example"
  echo "  ✅ Updated APP_NAME in .env.example"
fi

echo "🎉 Mobile app name successfully changed to \"$NEW_APP_NAME\"!"
