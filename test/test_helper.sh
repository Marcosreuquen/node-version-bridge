#!/usr/bin/env bash
# node-version-bridge — Test helper
# Common utilities for all test files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVB_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

export NVB_LOG_LEVEL="${NVB_LOG_LEVEL:-error}"

# Source all libraries
source "${NVB_ROOT}/lib/log.sh"
source "${NVB_ROOT}/lib/detect.sh"
source "${NVB_ROOT}/lib/parse.sh"
source "${NVB_ROOT}/lib/resolve.sh"
source "${NVB_ROOT}/lib/cache.sh"
source "${NVB_ROOT}/lib/manager.sh"

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

assert_eq() {
  local expected="$1" actual="$2" description="$3"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$expected" == "$actual" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "  ✓ ${description}"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  ✗ ${description}"
    echo "    expected: '${expected}'"
    echo "    actual:   '${actual}'"
  fi
}

assert_empty() {
  local actual="$1" description="$2"
  assert_eq "" "$actual" "$description"
}

assert_not_empty() {
  local actual="$1" description="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ -n "$actual" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "  ✓ ${description}"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  ✗ ${description} (expected non-empty, got empty)"
  fi
}

assert_fail() {
  local cmd="$1" description="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  if eval "$cmd" >/dev/null 2>&1; then
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  ✗ ${description} (expected failure but succeeded)"
  else
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "  ✓ ${description}"
  fi
}

# Create a temporary directory for test fixtures
setup_fixture() {
  mktemp -d
}

# Clean up a fixture directory
teardown_fixture() {
  local dir="$1"
  [[ -d "$dir" ]] && rm -rf "$dir"
}

# Print test results and return appropriate exit code
report() {
  echo ""
  echo "Results: ${TESTS_PASSED}/${TESTS_RUN} passed, ${TESTS_FAILED} failed"
  [[ $TESTS_FAILED -eq 0 ]]
}
