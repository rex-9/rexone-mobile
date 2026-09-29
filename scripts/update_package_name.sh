#!/usr/bin/env bash
# scripts/update_package_name.sh
# Usage: ./scripts/update_package_name.sh com.example.newapp

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "❌ Error: New package name required."
  echo "Usage: ./scripts/update_package_name.sh com.example.newapp"
  exit 1
fi

NEW_PACKAGE_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

sedi() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

echo "🔄 Changing App Package Name / Bundle ID to: \"$NEW_PACKAGE_NAME\"..."
cd "$ROOT_DIR"

# 1. Update Android Gradle configuration (build.gradle.kts)
if [ -f "$ROOT_DIR/android/app/build.gradle.kts" ]; then
  sedi -E "s/namespace = \"[^\"]+\"/namespace = \"$NEW_PACKAGE_NAME\"/g" "$ROOT_DIR/android/app/build.gradle.kts"
  sedi -E "s/applicationId = \"[^\"]+\"/applicationId = \"$NEW_PACKAGE_NAME\"/g" "$ROOT_DIR/android/app/build.gradle.kts"
  echo "  ✅ Android: Updated namespace and applicationId in build.gradle.kts"
fi

# 2. Update Android Kotlin MainActivity package and path
PACKAGE_PATH=$(echo "$NEW_PACKAGE_NAME" | tr '.' '/')
TARGET_KOTLIN_DIR="$ROOT_DIR/android/app/src/main/kotlin/$PACKAGE_PATH"
EXISTING_MAIN_KT=$(find "$ROOT_DIR/android/app/src/main/kotlin" -name "MainActivity.kt" 2>/dev/null | head -n 1)

if [ -n "$EXISTING_MAIN_KT" ] && [ -f "$EXISTING_MAIN_KT" ]; then
  mkdir -p "$TARGET_KOTLIN_DIR"
  if [ "$EXISTING_MAIN_KT" != "$TARGET_KOTLIN_DIR/MainActivity.kt" ]; then
    mv "$EXISTING_MAIN_KT" "$TARGET_KOTLIN_DIR/MainActivity.kt"
    find "$ROOT_DIR/android/app/src/main/kotlin" -type d -empty -delete 2>/dev/null || true
  fi
  sedi -E "s/^package [a-zA-Z0-9_.]+/package $NEW_PACKAGE_NAME/g" "$TARGET_KOTLIN_DIR/MainActivity.kt"
  echo "  ✅ Android: Relocated and updated MainActivity.kt -> $PACKAGE_PATH/MainActivity.kt"
fi

# 3. Update Android Patrol test runner (MainActivityTest.java) package and path
EXISTING_TEST_JAVA=$(find "$ROOT_DIR/android/app/src/androidTest/java" -name "MainActivityTest.java" 2>/dev/null | head -n 1)
TEST_PACKAGE_PATH="$PACKAGE_PATH"
TARGET_TEST_DIR="$ROOT_DIR/android/app/src/androidTest/java/$TEST_PACKAGE_PATH"
if [ -n "$EXISTING_TEST_JAVA" ] && [ -f "$EXISTING_TEST_JAVA" ]; then
  mkdir -p "$TARGET_TEST_DIR"
  if [ "$EXISTING_TEST_JAVA" != "$TARGET_TEST_DIR/MainActivityTest.java" ]; then
    mv "$EXISTING_TEST_JAVA" "$TARGET_TEST_DIR/MainActivityTest.java"
    find "$ROOT_DIR/android/app/src/androidTest/java" -type d -empty -delete 2>/dev/null || true
  fi
  sedi -E "s/^package [a-zA-Z0-9_.]+/package $NEW_PACKAGE_NAME/g" "$TARGET_TEST_DIR/MainActivityTest.java"
  echo "  ✅ Android: Relocated and updated MainActivityTest.java -> $TEST_PACKAGE_PATH/MainActivityTest.java"
fi

# 4. Update Android google-services.json.example (gitignored live files are NOT touched)
if [ -f "$ROOT_DIR/android/app/google-services.json.example" ]; then
  sedi -E "s/\"package_name\": \"[^\"]+\"/\"package_name\": \"$NEW_PACKAGE_NAME\"/g" "$ROOT_DIR/android/app/google-services.json.example"
  echo "  ✅ Android: Updated package_name in google-services.json.example"
fi
echo "  ℹ️  Android Firebase Note: Gitignored 'android/app/google-services.json' is intentionally untouched."
echo "     ⚠️  Developer Action Required: Download the official 'google-services.json' from Firebase Console for '$NEW_PACKAGE_NAME' and place it in 'android/app/'."

# 5. Update Linux CMakeLists.txt APPLICATION_ID
if [ -f "$ROOT_DIR/linux/CMakeLists.txt" ]; then
  sedi -E "s/set\(APPLICATION_ID \"[^\"]+\"\)/set(APPLICATION_ID \"$NEW_PACKAGE_NAME\")/g" "$ROOT_DIR/linux/CMakeLists.txt"
  echo "  ✅ Linux: Updated APPLICATION_ID in CMakeLists.txt"
fi

# 6. Update iOS Bundle Identifier in project.pbxproj safely without clobbering extensions
if [ -f "$ROOT_DIR/ios/Runner.xcodeproj/project.pbxproj" ]; then
  node -e "
    const fs = require('fs');
    const file = '$ROOT_DIR/ios/Runner.xcodeproj/project.pbxproj';
    if (fs.existsSync(file)) {
      let p = fs.readFileSync(file, 'utf8');
      p = p.replace(/PRODUCT_BUNDLE_IDENTIFIER = [a-zA-Z0-9_.]*?(RunnerTests|MediaDownloadWidget)?;/g, (m, suffix) => {
        if (suffix === 'RunnerTests') {
          return 'PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME.RunnerTests;';
        } else if (suffix === 'MediaDownloadWidget') {
          const widgetPkg = ('$NEW_PACKAGE_NAME' === 'com.rex9.rexone') ? 'com.rexone.mobile' : '$NEW_PACKAGE_NAME';
          return 'PRODUCT_BUNDLE_IDENTIFIER = ' + widgetPkg + '.MediaDownloadWidget;';
        }
        return 'PRODUCT_BUNDLE_IDENTIFIER = $NEW_PACKAGE_NAME;';
      });
      fs.writeFileSync(file, p);
    }
  " 2>/dev/null || true
  echo "  ✅ iOS: Updated PRODUCT_BUNDLE_IDENTIFIER in project.pbxproj"
fi

# 7. Update iOS GoogleService-Info.plist.example (gitignored live files are NOT touched)
if [ -f "$ROOT_DIR/ios/Runner/GoogleService-Info.plist.example" ]; then
  node -e "
    const fs = require('fs');
    let c = fs.readFileSync('$ROOT_DIR/ios/Runner/GoogleService-Info.plist.example', 'utf8');
    c = c.replace(/(<key>BUNDLE_ID<\/key>\s*<string>)[^<]*(<\/string>)/, '\$1$NEW_PACKAGE_NAME\$2');
    fs.writeFileSync('$ROOT_DIR/ios/Runner/GoogleService-Info.plist.example', c);
  " 2>/dev/null || true
  echo "  ✅ iOS: Updated bundle_id in GoogleService-Info.plist.example"
fi
echo "  ℹ️  iOS Firebase Note: Gitignored 'ios/Runner/GoogleService-Info.plist' is intentionally untouched."
echo "     ⚠️  Developer Action Required: Download the official 'GoogleService-Info.plist' from Firebase Console for '$NEW_PACKAGE_NAME' and place it in 'ios/Runner/'."

# 8. Update iOS App Group Entitlements & ActionStore
app_group_pkg="$NEW_PACKAGE_NAME"
if [ "$NEW_PACKAGE_NAME" = "com.rex9.rexone" ]; then
  app_group_pkg="com.rexone.mobile"
fi
for ent in "$ROOT_DIR/ios/Runner/Runner.entitlements" "$ROOT_DIR/ios/MediaDownloadWidgetExtension.entitlements"; do
  if [ -f "$ent" ]; then
    sedi -E "s|<string>group\.[a-zA-Z0-9_.]+</string>|<string>group.$app_group_pkg</string>|g" "$ent"
    echo "  ✅ iOS: Updated app group in $(basename "$ent")"
  fi
done
if [ -f "$ROOT_DIR/ios/MediaDownloadWidget/MediaDownloadLiveActivityActionStore.swift" ]; then
  sedi -E "s/static let appGroupId = \"group\.[^\"]+\"/static let appGroupId = \"group.$app_group_pkg\"/g" "$ROOT_DIR/ios/MediaDownloadWidget/MediaDownloadLiveActivityActionStore.swift"
  echo "  ✅ iOS: Updated appGroupId in MediaDownloadLiveActivityActionStore.swift"
fi

# 9. Update iOS Info.plist download background identifier
dl_pkg="$NEW_PACKAGE_NAME"
if [ "$NEW_PACKAGE_NAME" = "com.rex9.rexone" ]; then
  dl_pkg="com.rexone.mobile"
fi
if [ -f "$ROOT_DIR/ios/Runner/Info.plist" ]; then
  sedi -E "s|<string>[a-zA-Z0-9_.]+\.download</string>|<string>$dl_pkg.download</string>|g" "$ROOT_DIR/ios/Runner/Info.plist"
  echo "  ✅ iOS: Updated Info.plist download background identifier"
fi

# 10. Update patrol section in pubspec.yaml
if [ -f "$ROOT_DIR/pubspec.yaml" ]; then
  sedi -E "s/package_name:[[:space:]]*[a-zA-Z0-9_.]+/package_name: $NEW_PACKAGE_NAME/g" "$ROOT_DIR/pubspec.yaml"
  sedi -E "s/bundle_id:[[:space:]]*[a-zA-Z0-9_.]+/bundle_id: $NEW_PACKAGE_NAME/g" "$ROOT_DIR/pubspec.yaml"
  echo "  ✅ pubspec.yaml: Updated patrol package_name and bundle_id"
fi

echo "🎉 Package name / Bundle ID successfully changed to \"$NEW_PACKAGE_NAME\"!"
