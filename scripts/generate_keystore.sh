#!/usr/bin/env bash
# scripts/generate_keystore.sh
# Generates a standard Android Release Upload Keystore & Base64 Secret
# Saves in two safe locations:
#   1. Global Android directory: ~/.android/keystores/
#   2. Local project root & android/app/ (strictly gitignored via *.jks, *.pem)
# Usage: ./scripts/generate_keystore.sh [app_name] [alias]
# Example: ./scripts/generate_keystore.sh rexone upload

set -euo pipefail

APP_NAME="${1:-rexone}"
KEY_ALIAS="${2:-upload}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

echo "============================================================"
echo "🔐  ANDROID RELEASE UPLOAD KEYSTORE GENERATOR"
echo "============================================================"
echo "📱 App Identifier: $APP_NAME"
echo "🔑 Key Alias:      $KEY_ALIAS"
echo "------------------------------------------------------------"

# Locate keytool
KEYTOOL_CMD="keytool"
if ! command -v keytool &> /dev/null; then
  if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/keytool" ]; then
    KEYTOOL_CMD="$JAVA_HOME/bin/keytool"
  elif [ -x "/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" ]; then
    KEYTOOL_CMD="/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool"
  else
    echo "❌ Error: 'keytool' not found. Please ensure Java JDK is installed and in your PATH."
    exit 1
  fi
fi

# Location 1: Global system Android directory
GLOBAL_DIR="$HOME/.android/keystores"
mkdir -p "$GLOBAL_DIR"
chmod 700 "$GLOBAL_DIR"

GLOBAL_KEYSTORE="$GLOBAL_DIR/${APP_NAME}-upload-keystore.jks"
GLOBAL_CERT="$GLOBAL_DIR/${APP_NAME}-upload-cert.pem"

# Location 2: Project keystores directory (gitignored)
LOCAL_DIR="$ROOT_DIR/android/keystores"
mkdir -p "$LOCAL_DIR"
chmod 700 "$LOCAL_DIR"

LOCAL_KEYSTORE="$LOCAL_DIR/${APP_NAME}-upload-keystore.jks"
LOCAL_CERT="$LOCAL_DIR/${APP_NAME}-upload-cert.pem"
GRADLE_KEYSTORE="$ROOT_DIR/android/app/upload-keystore.jks"

if [ -f "$GLOBAL_KEYSTORE" ] || [ -f "$LOCAL_KEYSTORE" ]; then
  echo "⚠️ Warning: Keystore already exists at one or more locations:"
  [ -f "$GLOBAL_KEYSTORE" ] && echo "   • $GLOBAL_KEYSTORE"
  [ -f "$LOCAL_KEYSTORE" ] && echo "   • $LOCAL_KEYSTORE"
  echo ""
  read -r -p "Overwrite existing keystore files? (y/N): " confirm_overwrite
  if [[ ! "$confirm_overwrite" =~ ^[Yy]$ ]]; then
    echo "Operation aborted. Keystores preserved."
    exit 0
  fi
  rm -f "$GLOBAL_KEYSTORE" "$GLOBAL_CERT" "$LOCAL_KEYSTORE" "$LOCAL_CERT" "$GRADLE_KEYSTORE"
fi

# Prompt for passwords securely
echo ""
echo "🔒 Enter passwords for your release keystore."
while true; do
  read -r -s -p "Enter Keystore Password (min 6 chars): " KEY_PASSWORD
  echo ""
  read -r -s -p "Confirm Keystore Password: " KEY_PASSWORD_CONFIRM
  echo ""

  if [ ${#KEY_PASSWORD} -lt 6 ]; then
    echo "❌ Password must be at least 6 characters. Please try again."
    continue
  fi

  if [ "$KEY_PASSWORD" != "$KEY_PASSWORD_CONFIRM" ]; then
    echo "❌ Passwords do not match. Please try again."
    continue
  fi
  break
done

echo ""
echo "📝 Keystore Distinguished Name Details (Press Enter to accept defaults):"
read -r -p "Your First and Last Name [Rex Naing]: " DNAME_CN
DNAME_CN="${DNAME_CN:-Rex Naing}"
read -r -p "Organizational Unit [Mobile Engineering]: " DNAME_OU
DNAME_OU="${DNAME_OU:-Mobile Engineering}"
read -r -p "Organization [Rex9]: " DNAME_O
DNAME_O="${DNAME_O:-Rex9}"
read -r -p "Two-letter Country Code [US]: " DNAME_C
DNAME_C="${DNAME_C:-US}"

DNAME="CN=${DNAME_CN}, OU=${DNAME_OU}, O=${DNAME_O}, C=${DNAME_C}"

echo ""
echo "🔨 Generating 2048-bit RSA upload keystore in primary location..."

"$KEYTOOL_CMD" -genkeypair \
  -v \
  -keystore "$GLOBAL_KEYSTORE" \
  -storepass "$KEY_PASSWORD" \
  -keypass "$KEY_PASSWORD" \
  -alias "$KEY_ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -dname "$DNAME"

chmod 600 "$GLOBAL_KEYSTORE"

# Export public certificate (.pem) - needed if Google Play ever requests upload key registration or reset
"$KEYTOOL_CMD" -export \
  -rfc \
  -keystore "$GLOBAL_KEYSTORE" \
  -storepass "$KEY_PASSWORD" \
  -alias "$KEY_ALIAS" \
  -file "$GLOBAL_CERT"

chmod 600 "$GLOBAL_CERT"

# Copy to Location 2: Project keystores directory (gitignored)
echo "📦 Copying duplicate to $LOCAL_DIR/ and android/app/..."
cp "$GLOBAL_KEYSTORE" "$LOCAL_KEYSTORE"
cp "$GLOBAL_CERT" "$LOCAL_CERT"
mkdir -p "$ROOT_DIR/android/app"
cp "$GLOBAL_KEYSTORE" "$GRADLE_KEYSTORE"

chmod 600 "$LOCAL_KEYSTORE" "$LOCAL_CERT" "$GRADLE_KEYSTORE"

# Base64 encode the keystore and copy to clipboard
BASE64_OUTPUT=$(base64 < "$GLOBAL_KEYSTORE" | tr -d '\n')

COPIED_TO_CLIPBOARD=false
if [[ "$OSTYPE" == "darwin"* ]] && command -v pbcopy &> /dev/null; then
  echo "$BASE64_OUTPUT" | pbcopy
  COPIED_TO_CLIPBOARD=true
fi

echo "============================================================"
echo "🎉 SUCCESS: Upload keystore generated in 2 safe places!"
echo "============================================================"
echo "📍 Place 1 (Global System Backup):"
echo "   • Keystore: $GLOBAL_KEYSTORE"
echo "   • Cert:     $GLOBAL_CERT"
echo ""
echo "📍 Place 2 (Project Keystores Directory - gitignored):"
echo "   • Project:  $LOCAL_KEYSTORE"
echo "   • Gradle:   $GRADLE_KEYSTORE"
echo "   • Cert:     $LOCAL_CERT"
echo ""
echo "🔑 Key Alias: $KEY_ALIAS"
echo "------------------------------------------------------------"

if [ "$COPIED_TO_CLIPBOARD" = true ]; then
  echo "📋 [COPIED] Base64 string is already in your macOS clipboard!"
  echo "   You can immediately paste it into GitHub Secret: ANDROID_KEYSTORE_BASE64"
else
  echo "📋 Base64 string command to copy manually:"
  echo "   base64 < \"$LOCAL_KEYSTORE\" | pbcopy"
fi

echo "------------------------------------------------------------"
echo "🔐 GITHUB REPOSITORY SECRETS TO CONFIGURE:"
echo "👉 https://github.com/rex-9/rexone_mobile/settings/secrets/actions"
echo ""
echo "  1. ANDROID_KEYSTORE_BASE64 = (Pasted from clipboard)"
echo "  2. KEYSTORE_PASSWORD       = [The password you entered]"
echo "  3. KEY_ALIAS               = $KEY_ALIAS"
echo "  4. KEY_PASSWORD            = [Same as keystore password]"
echo "============================================================"
echo "💡 SAFETY & BACKUP NOTES:"
echo "   • Both .jks and .pem files are strictly gitignored in .gitignore."
echo "   • Place 1 (~/.android/keystores) remains safe even if you git clean."
echo "   • Place 2 ($ROOT_DIR) is easily accessible right here in your project."
echo "   • If ever needed, you can reset this key in Google Play Console"
echo "     (Setup > App integrity) using the public certificate ($LOCAL_CERT)."
echo "============================================================"
