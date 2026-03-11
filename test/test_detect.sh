#!/usr/bin/env bash
# node-version-bridge — Detection tests

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_helper.sh"

echo "=== Detection Tests ==="

echo ""
echo "File detection:"

# Single file in directory
dir="$(setup_fixture)"
echo "18.19.0" > "${dir}/.nvmrc"
result="$(nvb_detect_file ".nvmrc" "$dir")"
assert_eq "${dir}/.nvmrc" "$result" "finds .nvmrc in current dir"
teardown_fixture "$dir"

# File in parent directory
dir="$(setup_fixture)"
mkdir -p "${dir}/sub/deep"
echo "18.19.0" > "${dir}/.nvmrc"
result="$(nvb_detect_file ".nvmrc" "${dir}/sub/deep")"
assert_eq "${dir}/.nvmrc" "$result" "walks up to find .nvmrc in parent"
teardown_fixture "$dir"

# File not found
dir="$(setup_fixture)"
result="$(nvb_detect_file ".nvmrc" "$dir" 2>/dev/null)" || result=""
assert_empty "$result" "returns empty when file not found"
teardown_fixture "$dir"

# Multiple files — closest wins
dir="$(setup_fixture)"
mkdir -p "${dir}/sub"
echo "18.0.0" > "${dir}/.nvmrc"
echo "20.0.0" > "${dir}/sub/.nvmrc"
result="$(nvb_detect_file ".nvmrc" "${dir}/sub")"
assert_eq "${dir}/sub/.nvmrc" "$result" "finds closest file first"
teardown_fixture "$dir"

# Different file types in same directory
dir="$(setup_fixture)"
echo "18.19.0" > "${dir}/.nvmrc"
echo "20.11.0" > "${dir}/.node-version"
echo "nodejs 22.0.0" > "${dir}/.tool-versions"

result="$(nvb_detect_file ".nvmrc" "$dir")"
assert_eq "${dir}/.nvmrc" "$result" "detects .nvmrc"

result="$(nvb_detect_file ".node-version" "$dir")"
assert_eq "${dir}/.node-version" "$result" "detects .node-version"

result="$(nvb_detect_file ".tool-versions" "$dir")"
assert_eq "${dir}/.tool-versions" "$result" "detects .tool-versions"

teardown_fixture "$dir"

report
