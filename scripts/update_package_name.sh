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

# 1. Change native package name via change_app_package_name
dart run change_app_package_name:main "$NEW_PACKAGE_NAME"

# 2. Update patrol section in pubspec.yaml
if [ -f "$ROOT_DIR/pubspec.yaml" ]; then
  sedi -E "s/package_name:\s*[a-zA-Z0-9_.]+/package_name: $NEW_PACKAGE_NAME/g" "$ROOT_DIR/pubspec.yaml"
  sedi -E "s/bundle_id:\s*[a-zA-Z0-9_.]+/bundle_id: $NEW_PACKAGE_NAME/g" "$ROOT_DIR/pubspec.yaml"
  echo "  ✅ pubspec.yaml: Updated patrol package_name and bundle_id"
fi

echo "🎉 Package name / Bundle ID successfully changed to \"$NEW_PACKAGE_NAME\"!"
