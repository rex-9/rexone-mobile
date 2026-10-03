#!/usr/bin/env bash
# scripts/rebrand.sh
# Unified Mobile Rebranding Script
# Usage: ./scripts/rebrand.sh "New App Name" "com.company.newapp" [optional_logo_path] [optional_brand_name] [optional_domain]

set -euo pipefail

APP_NAME="${1:-}"
PACKAGE_NAME="${2:-}"
LOGO_PATH="${3:-}"
BRAND_NAME="${4:-$APP_NAME}"
BRAND_DOMAIN="${5:-rexone.com}"
FROM_EMAIL="${6:-}"
if [ -z "$FROM_EMAIL" ]; then
  if [ "$BRAND_NAME" = "RexOne" ]; then
    FROM_EMAIL="support@rexone.com"
  else
    FROM_EMAIL="support@${BRAND_DOMAIN}"
  fi
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

BRAND_SLUG_KEBAB=$(echo "$BRAND_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g')
BRAND_SLUG_SNAKE=$(echo "$BRAND_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g' | sed -E 's/^-+|-+$//g')
BRAND_SLUG_FLAT=$(echo "$BRAND_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+//g')

sedi() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

if [ -z "$APP_NAME" ]; then
  echo "📱 Mobile Rebrand Script"
  echo "----------------------------------------"
  echo "💡 TIP: For full cross-platform sync (Web, Mobile, Core), run:"
  echo "   cd ../rexone-core && ./scripts/rebrand.sh"
  echo "----------------------------------------"
  echo "Usage: ./scripts/rebrand.sh \"New App Name\" \"com.company.newapp\" [path/to/logo.png] [BrandName] [domain]"
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
  sedi -E "s/welcomeHome: 'Welcome to [^'!]+!/welcomeHome: 'Welcome to $BRAND_NAME!/g" "$ROOT_DIR/lib/locales/app_translations.dart"
  sedi -E "s/✨ Welcome to [^'✨]+ ✨/✨ Welcome to $BRAND_NAME ✨/g" "$ROOT_DIR/lib/locales/app_translations.dart"
  sedi -E "s/to help improve [^.]+\./to help improve $BRAND_NAME./g" "$ROOT_DIR/lib/locales/app_translations.dart"
  sedi -E "s/Available on [^']+ Web/Available on $BRAND_NAME Web/g" "$ROOT_DIR/lib/locales/app_translations.dart"
  sedi -E "s/managed in the [^']+ Web admin portal/managed in the $BRAND_NAME Web admin portal/g" "$ROOT_DIR/lib/locales/app_translations.dart"
  sedi -E "s/This link will leave [^']+ and open/This link will leave $BRAND_NAME and open/g" "$ROOT_DIR/lib/locales/app_translations.dart"
  sedi -E "s/welcomeHome: '[^']+ မှ ကြိုဆိုပါတယ်!/welcomeHome: '$BRAND_NAME မှ ကြိုဆိုပါတယ်!/g" "$ROOT_DIR/lib/locales/app_translations.dart"
  sedi -E "s/✨ [^'✨]+ မှ ကြိုဆိုပါသည် ✨/✨ $BRAND_NAME မှ ကြိုဆိုပါသည် ✨/g" "$ROOT_DIR/lib/locales/app_translations.dart"
  sedi -E "s/'[^']+ ပိုမိုကောင်းမွန်စေရန်/'$BRAND_NAME ပိုမိုကောင်းမွန်စေရန်/g" "$ROOT_DIR/lib/locales/app_translations.dart"
  sedi -E "s/webOnlyTitle: '[^']+ Web တွင် ရနိုင်သည်'/webOnlyTitle: '$BRAND_NAME Web တွင် ရနိုင်သည်'/g" "$ROOT_DIR/lib/locales/app_translations.dart"
  sedi -E "s/ဤအပြောင်းအလဲကို [^']+ Web admin portal/ဤအပြောင်းအလဲကို $BRAND_NAME Web admin portal/g" "$ROOT_DIR/lib/locales/app_translations.dart"
  sedi -E "s/ဤလင့်ခ်သည် [^']+ မှထွက်ပြီး/ဤလင့်ခ်သည် $BRAND_NAME မှထွက်ပြီး/g" "$ROOT_DIR/lib/locales/app_translations.dart"
  echo "  ✅ AppTranslations: Synchronized brand display name ($BRAND_NAME)"
fi

# 5. Synchronize Android/iOS app IDs and API Base URL in .env.example (Law U16 & Secret Isolation)
if [ -f "$ROOT_DIR/.env.example" ]; then
  if [ -n "$PACKAGE_NAME" ]; then
    sedi -E "s/^ANDROID_APP_ID=.*/ANDROID_APP_ID=$PACKAGE_NAME/g" "$ROOT_DIR/.env.example"
    sedi -E "s/^IOS_APP_ID=.*/IOS_APP_ID=$PACKAGE_NAME/g" "$ROOT_DIR/.env.example"
  fi
  api_domain="$BRAND_DOMAIN"
  if [ "$BRAND_NAME" = "RexOne" ]; then
    api_domain="rexone.com"
  fi
  sedi -E "s|^API_BASE_URL=https?://api\.[^/]+|API_BASE_URL=https://api.$api_domain|g" "$ROOT_DIR/.env.example"
  if grep -q "^FROM_EMAIL=" "$ROOT_DIR/.env.example"; then
    sedi -E "s/^FROM_EMAIL=.*/FROM_EMAIL=$FROM_EMAIL/g" "$ROOT_DIR/.env.example"
  else
    echo "FROM_EMAIL=$FROM_EMAIL" >> "$ROOT_DIR/.env.example"
  fi
  echo "  ✅ Mobile: Updated .env.example"
fi

# 6. Synchronize default fallbacks in lib/config/app.config.dart
if [ -f "$ROOT_DIR/lib/config/app.config.dart" ]; then
  if [ -n "$PACKAGE_NAME" ]; then
    sedi -E "s/(androidAppIdKey\] \?\? ')[^']+'/\1$PACKAGE_NAME'/g" "$ROOT_DIR/lib/config/app.config.dart"
    sedi -E "s/(iosAppIdKey\] \?\? ')[^']+'/\1$PACKAGE_NAME'/g" "$ROOT_DIR/lib/config/app.config.dart"
  fi
  app_name_fallback="$APP_NAME"
  if [ "$BRAND_NAME" = "RexOne" ]; then
    app_name_fallback="RexOne"
  fi
  sedi -E "s/dotenv\.env\[AppConstants\.nameKey\] \?\? '[^']+'/dotenv.env[AppConstants.nameKey] ?? '$app_name_fallback'/g" "$ROOT_DIR/lib/config/app.config.dart"
  sedi -E "s/dotenv\.env\[AppConstants\.fromEmailKey\] \?\? '[^']+'/dotenv.env[AppConstants.fromEmailKey] ?? '$FROM_EMAIL'/g" "$ROOT_DIR/lib/config/app.config.dart"
  echo "  ✅ app.config.dart: Updated default app name, email, and ID fallbacks ($app_name_fallback / $PACKAGE_NAME)"
fi

# 7. Synchronize app info helper fallbacks in lib/helpers/app_info.helper.dart
if [ -f "$ROOT_DIR/lib/helpers/app_info.helper.dart" ]; then
  app_name_fallback="$APP_NAME"
  if [ "$BRAND_NAME" = "RexOne" ]; then
    app_name_fallback="RexOne"
  fi
  sedi -E "s/appName: '[^']+'/appName: '$app_name_fallback'/g" "$ROOT_DIR/lib/helpers/app_info.helper.dart"
  if [ -n "$PACKAGE_NAME" ]; then
    sedi -E "s/packageName: '[^']+'/packageName: '$PACKAGE_NAME'/g" "$ROOT_DIR/lib/helpers/app_info.helper.dart"
  fi
  echo "  ✅ app_info.helper.dart: Updated default appName and packageName ($app_name_fallback / $PACKAGE_NAME)"
fi

# 8. Synchronize local Drift database name in lib/data/local/database.dart
if [ -f "$ROOT_DIR/lib/data/local/database.dart" ]; then
  sedi -E "s/driftDatabase\(name: '[^']+'\)/driftDatabase(name: '${BRAND_SLUG_SNAKE}_offline')/g" "$ROOT_DIR/lib/data/local/database.dart"
  echo "  ✅ database.dart: Updated local drift database name to ${BRAND_SLUG_SNAKE}_offline"
fi

# 9. Synchronize secure storage salt seed in lib/services/storage.service.dart
if [ -f "$ROOT_DIR/lib/services/storage.service.dart" ]; then
  sedi -E "s/static const String _saltSeed = '[^']+';/static const String _saltSeed = '${BRAND_SLUG_SNAKE}_mobile_auth_secure_seed_2026';/g" "$ROOT_DIR/lib/services/storage.service.dart"
  echo "  ✅ storage.service.dart: Updated secure storage salt seed"
fi

# 10. Synchronize method channels in Dart and Swift
if [ -f "$ROOT_DIR/lib/modules/media/audio/services/now_playing.bridge.dart" ]; then
  sedi -E "s/MethodChannel\('[^']+\/now_playing'\)/MethodChannel('${BRAND_SLUG_KEBAB}\/now_playing')/g" "$ROOT_DIR/lib/modules/media/audio/services/now_playing.bridge.dart"
fi
if [ -f "$ROOT_DIR/lib/constants/media_download.constants.dart" ]; then
  sedi -E "s/'[a-zA-Z0-9_-]+\/media_download_live_activity'/'${BRAND_SLUG_KEBAB}\/media_download_live_activity'/g" "$ROOT_DIR/lib/constants/media_download.constants.dart"
  sedi -E "s/static const keySalt = '[^']+';/static const keySalt = '${BRAND_SLUG_SNAKE}_mobile_offline_v1';/g" "$ROOT_DIR/lib/constants/media_download.constants.dart"
fi
if [ -f "$ROOT_DIR/ios/Runner/AppDelegate.swift" ]; then
  sedi -E "s/name: \"[^\"]+\/now_playing\"/name: \"${BRAND_SLUG_KEBAB}\/now_playing\"/g" "$ROOT_DIR/ios/Runner/AppDelegate.swift"
  sedi -E "s/name: \"[^\"]+\/media_download_live_activity\"/name: \"${BRAND_SLUG_KEBAB}\/media_download_live_activity\"/g" "$ROOT_DIR/ios/Runner/AppDelegate.swift"
  echo "  ✅ iOS/Dart: Updated platform method channel names to ${BRAND_SLUG_KEBAB}"
fi

# 11. Synchronize iOS URL Scheme in Info.plist
if [ -f "$ROOT_DIR/ios/Runner/Info.plist" ]; then
  url_scheme="${BRAND_SLUG_FLAT}"
  if [ "$BRAND_NAME" = "RexOne" ]; then
    url_scheme="rexone"
  fi
  node -e "
    const fs = require('fs');
    let c = fs.readFileSync('$ROOT_DIR/ios/Runner/Info.plist', 'utf8');
    c = c.replace(/(<key>CFBundleURLName<\/key>\s*<string>[^<]*<\/string>\s*<key>CFBundleURLSchemes<\/key>\s*<array>\s*<string>)[^<]*(<\/string>)/, '\$1$url_scheme\$2');
    fs.writeFileSync('$ROOT_DIR/ios/Runner/Info.plist', c);
  " 2>/dev/null || true
  echo "  ✅ iOS: Updated URL scheme to $url_scheme"
fi

# 12. Synchronize Firebase project_id and storage_bucket in example templates
fb_project_id="${BRAND_SLUG_KEBAB}"
fb_storage_bucket="${BRAND_SLUG_KEBAB}.firebasestorage.app"
if [ "$BRAND_NAME" = "RexOne" ]; then
  fb_project_id="YOUR_PROJECT_ID"
  fb_storage_bucket="YOUR_PROJECT_ID.firebasestorage.app"
fi
if [ -f "$ROOT_DIR/android/app/google-services.json.example" ]; then
  sedi -E "s/\"project_id\": \"[^\"]+\"/\"project_id\": \"$fb_project_id\"/g" "$ROOT_DIR/android/app/google-services.json.example"
  sedi -E "s/\"storage_bucket\": \"[^\"]+\"/\"storage_bucket\": \"$fb_storage_bucket\"/g" "$ROOT_DIR/android/app/google-services.json.example"
fi
if [ -f "$ROOT_DIR/ios/Runner/GoogleService-Info.plist.example" ]; then
  node -e "
    const fs = require('fs');
    let c = fs.readFileSync('$ROOT_DIR/ios/Runner/GoogleService-Info.plist.example', 'utf8');
    c = c.replace(/(<key>PROJECT_ID<\/key>\s*<string>)[^<]*(<\/string>)/, '\$1$fb_project_id\$2');
    c = c.replace(/(<key>STORAGE_BUCKET<\/key>\s*<string>)[^<]*(<\/string>)/, '\$1$fb_storage_bucket\$2');
    fs.writeFileSync('$ROOT_DIR/ios/Runner/GoogleService-Info.plist.example', c);
  " 2>/dev/null || true
fi

echo "  ℹ️  Credential Isolation Note: Gitignored files (.env, google-services.json, GoogleService-Info.plist) are untouched."
echo "     ⚠️  Developer Action Required: Download official configuration files from Firebase Console and update local .env credentials manually."

echo "✨ Mobile rebranding complete! ✨"
