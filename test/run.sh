#!/usr/bin/env bash
# node-version-bridge — Test runner
# Runs all test files and reports aggregate results

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "node-version-bridge — Test Suite"
echo "================================"
echo ""

TOTAL_EXIT=0

for test_file in "${SCRIPT_DIR}"/test_*.sh; do
  [[ "$(basename "$test_file")" == "test_helper.sh" ]] && continue

  echo ""
  if bash "$test_file"; then
    : # passed
  else
    TOTAL_EXIT=1
  fi
  echo ""
done

echo "================================"
if [[ $TOTAL_EXIT -eq 0 ]]; then
  echo "All test suites passed."
else
  echo "Some tests failed."
fi

exit $TOTAL_EXIT
