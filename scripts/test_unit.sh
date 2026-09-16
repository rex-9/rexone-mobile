#!/usr/bin/env bash

# ==============================================================================
# RexOne Mobile — Unit Test Runner (Flutter Test)
#
# Usage:
#   ./scripts/test_unit.sh [file|filter] [options]
#
# Examples:
#   ./scripts/test_unit.sh                                    # Run all unit tests
#   ./scripts/test_unit.sh test/controllers/                  # Run all controller tests
#   ./scripts/test_unit.sh test/controllers/socket_controller_test.dart
#   ./scripts/test_unit.sh --coverage                         # Run with code coverage
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Add Dart / Flutter pub cache to PATH if present
export PATH="$PATH:$HOME/.pub-cache/bin:${PUB_CACHE:-$HOME/.pub-cache}/bin"

echo "===================================================="
echo " ⚡ RexOne Mobile — Unit Tests (Flutter Test)"
echo "===================================================="

flutter test "$@"
