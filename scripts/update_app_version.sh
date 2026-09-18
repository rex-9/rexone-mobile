#!/usr/bin/env bash
# scripts/update_app_version.sh
# Usage: ./scripts/update_app_version.sh 1.0.1

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: ./scripts/update_app_version.sh <new_version>"
  echo "Example: ./scripts/update_app_version.sh 1.0.1"
  exit 1
fi

NEW_VERSION="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

sedi() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

# Read current build number or default to 0
CURRENT_BUILD=$(grep -E '^\s*version:' pubspec.yaml | sed -E 's/.*\+([0-9]+).*/\1/' || true)
if ! [[ "$CURRENT_BUILD" =~ ^[0-9]+$ ]]; then
  CURRENT_BUILD=0
fi

NEW_BUILD=$((CURRENT_BUILD + 1))

# Update pubspec.yaml
sedi -E "s/version: .*/version: $NEW_VERSION+$NEW_BUILD/" pubspec.yaml

echo "✅ Version updated to: $NEW_VERSION+$NEW_BUILD"