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

app_display_base="$NEW_APP_NAME"
if [ "$NEW_APP_NAME" = "RexOne Mobile" ] || [ "$NEW_APP_NAME" = "RexOne" ]; then
  app_display_base="RexOne"
elif [[ "$NEW_APP_NAME" == *" Mobile" ]]; then
  app_display_base="${NEW_APP_NAME% Mobile}"
fi

# 1. Android Gradle configuration (manifestPlaceholders["appName"]) & AndroidManifest.xml
if [ -f "$ROOT_DIR/android/app/build.gradle.kts" ]; then
  if grep -q 'manifestPlaceholders\["appName"\]' "$ROOT_DIR/android/app/build.gradle.kts"; then
    sedi -E "s/manifestPlaceholders\[\"appName\"\] = if \(isUat\) \"[^\"]+\" else \"[^\"]+\"/manifestPlaceholders[\"appName\"] = if (isUat) \"$app_display_base UAT\" else \"$app_display_base\"/g" "$ROOT_DIR/android/app/build.gradle.kts"
    echo "  ✅ Android: Updated manifestPlaceholders[\"appName\"] in build.gradle.kts ($app_display_base)"
  fi
fi

if [ -f "$ROOT_DIR/android/app/src/main/AndroidManifest.xml" ]; then
  if ! grep -q 'android:label="\${appName}"' "$ROOT_DIR/android/app/src/main/AndroidManifest.xml"; then
    sedi -E 's/android:label="[^"]*"/android:label="${appName}"/g' "$ROOT_DIR/android/app/src/main/AndroidManifest.xml"
  fi
  echo "  ✅ Android: Preserved dynamic android:label=\"\${appName}\" in AndroidManifest.xml"
fi

# 2. iOS Info.plist (CFBundleDisplayName & CFBundleName)
if [ -f "$ROOT_DIR/ios/Runner/Info.plist" ]; then
  cf_display_name="$NEW_APP_NAME"
  cf_bundle_name="$NEW_APP_NAME"
  if [ "$NEW_APP_NAME" = "RexOne" ] || [ "$NEW_APP_NAME" = "RexOne Mobile" ]; then
    cf_display_name="RexOne Mobile"
    cf_bundle_name="rexone_mobile"
  fi

  python3 -c "
import os, re
f = '$ROOT_DIR/ios/Runner/Info.plist'
if os.path.exists(f):
    with open(f, 'r') as fp:
        c = fp.read()
    c = re.sub(r'(<key>CFBundleDisplayName<\/key>\s*<string>)[^<]*(<\/string>)', r'\g<1>$cf_display_name\g<2>', c)
    c = re.sub(r'(<key>CFBundleName<\/key>\s*(?:<!--[^\n]*-->\s*)?<string>)[^<]*(<\/string>)', r'\g<1>$cf_bundle_name\g<2>', c)
    with open(f, 'w') as fp:
        fp.write(c)
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

# 5. release_android.sh default app name
if [ -f "$ROOT_DIR/scripts/release_android.sh" ]; then
  sedi -E "s/DEFAULT_APP_BASE=\"[^\"]*\"/DEFAULT_APP_BASE=\"$app_display_base\"/g" "$ROOT_DIR/scripts/release_android.sh"
  echo "  ✅ release_android.sh: Updated DEFAULT_APP_BASE ($app_display_base)"
fi

# 6. release_ios.sh default app name
if [ -f "$ROOT_DIR/scripts/release_ios.sh" ]; then
  sedi -E "s/DEFAULT_APP_BASE=\"[^\"]*\"/DEFAULT_APP_BASE=\"$app_display_base\"/g" "$ROOT_DIR/scripts/release_ios.sh"
  echo "  ✅ release_ios.sh: Updated DEFAULT_APP_BASE ($app_display_base)"
fi

echo "🎉 Mobile app name successfully changed to \"$NEW_APP_NAME\"!"
