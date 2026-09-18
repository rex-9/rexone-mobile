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
  sedi -E "s/android:label=\"[^\"]*\"/android:label=\"$NEW_APP_NAME\"/g" "$ROOT_DIR/android/app/src/main/AndroidManifest.xml"
  echo "  ✅ Android: Updated android:label in AndroidManifest.xml"
fi

# 2. iOS Info.plist (CFBundleDisplayName & CFBundleName)
if [ -f "$ROOT_DIR/ios/Runner/Info.plist" ]; then
  # CFBundleDisplayName
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $NEW_APP_NAME" "$ROOT_DIR/ios/Runner/Info.plist" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string $NEW_APP_NAME" "$ROOT_DIR/ios/Runner/Info.plist" 2>/dev/null || true

  # CFBundleName
  /usr/libexec/PlistBuddy -c "Set :CFBundleName $NEW_APP_NAME" "$ROOT_DIR/ios/Runner/Info.plist" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Add :CFBundleName string $NEW_APP_NAME" "$ROOT_DIR/ios/Runner/Info.plist" 2>/dev/null || true

  echo "  ✅ iOS: Updated CFBundleDisplayName and CFBundleName in Info.plist"
fi

# 3. pubspec.yaml description & patrol app_name
if [ -f "$ROOT_DIR/pubspec.yaml" ]; then
  sedi -E "s/^description: .*/description: $NEW_APP_NAME # \$APP_NAME/g" "$ROOT_DIR/pubspec.yaml"
  sedi -E "s/app_name:\s*.*/app_name: $NEW_APP_NAME/g" "$ROOT_DIR/pubspec.yaml"
  echo "  ✅ pubspec.yaml: Updated description and patrol app_name"
fi

# 4. Environment files (.env.dev, .env.uat, .env.prod)
for env_file in "$ROOT_DIR"/.env*; do
  if [ -f "$env_file" ] && grep -q "APP_NAME=" "$env_file"; then
    sedi -E "s/^APP_NAME=.*/APP_NAME=\"$NEW_APP_NAME\"/g" "$env_file"
    echo "  ✅ Updated APP_NAME in $(basename "$env_file")"
  fi
done

echo "🎉 Mobile app name successfully changed to \"$NEW_APP_NAME\"!"
