#!/usr/bin/env bash
# node-version-bridge — Parse tests

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_helper.sh"

echo "=== Parse Tests ==="

# --- .nvmrc parsing ---

echo ""
echo ".nvmrc parsing:"

dir="$(setup_fixture)"

echo "18.19.0" > "${dir}/.nvmrc"
result="$(nvb_parse_nvmrc "${dir}/.nvmrc")"
assert_eq "18.19.0" "$result" "parses plain semver"

echo "v18.19.0" > "${dir}/.nvmrc"
result="$(nvb_parse_nvmrc "${dir}/.nvmrc")"
assert_eq "18.19.0" "$result" "strips leading v"

echo "V20.11.1" > "${dir}/.nvmrc"
result="$(nvb_parse_nvmrc "${dir}/.nvmrc")"
assert_eq "20.11.1" "$result" "strips leading V (uppercase)"

echo "18" > "${dir}/.nvmrc"
result="$(nvb_parse_nvmrc "${dir}/.nvmrc")"
assert_eq "18" "$result" "accepts major-only version"

echo "18.19" > "${dir}/.nvmrc"
result="$(nvb_parse_nvmrc "${dir}/.nvmrc")"
assert_eq "18.19" "$result" "accepts major.minor version"

echo "  v18.19.0  " > "${dir}/.nvmrc"
result="$(nvb_parse_nvmrc "${dir}/.nvmrc")"
assert_eq "18.19.0" "$result" "handles whitespace"

echo "" > "${dir}/.nvmrc"
result="$(nvb_parse_nvmrc "${dir}/.nvmrc" 2>/dev/null)" || result=""
assert_empty "$result" "returns empty for blank file"

echo "lts/*" > "${dir}/.nvmrc"
result="$(nvb_parse_nvmrc "${dir}/.nvmrc" 2>/dev/null)" || result=""
assert_empty "$result" "rejects lts alias"

echo "node" > "${dir}/.nvmrc"
result="$(nvb_parse_nvmrc "${dir}/.nvmrc" 2>/dev/null)" || result=""
assert_empty "$result" "rejects node alias"

echo "not-a-version" > "${dir}/.nvmrc"
result="$(nvb_parse_nvmrc "${dir}/.nvmrc" 2>/dev/null)" || result=""
assert_empty "$result" "rejects invalid format"

teardown_fixture "$dir"

# --- .node-version parsing ---

echo ""
echo ".node-version parsing:"

dir="$(setup_fixture)"

echo "20.11.0" > "${dir}/.node-version"
result="$(nvb_parse_node_version "${dir}/.node-version")"
assert_eq "20.11.0" "$result" "parses .node-version"

echo "v22.0.0" > "${dir}/.node-version"
result="$(nvb_parse_node_version "${dir}/.node-version")"
assert_eq "22.0.0" "$result" "strips v prefix"

teardown_fixture "$dir"

# --- .tool-versions parsing ---

echo ""
echo ".tool-versions parsing:"

dir="$(setup_fixture)"

echo "nodejs 18.19.0" > "${dir}/.tool-versions"
result="$(nvb_parse_tool_versions "${dir}/.tool-versions")"
assert_eq "18.19.0" "$result" "parses nodejs entry"

printf "python 3.11.0\nnodejs 20.10.0\nruby 3.2.0\n" > "${dir}/.tool-versions"
result="$(nvb_parse_tool_versions "${dir}/.tool-versions")"
assert_eq "20.10.0" "$result" "extracts nodejs from multi-tool file"

echo "node 22.0.0" > "${dir}/.tool-versions"
result="$(nvb_parse_tool_versions "${dir}/.tool-versions")"
assert_eq "22.0.0" "$result" "accepts 'node' as well as 'nodejs'"

echo "python 3.11.0" > "${dir}/.tool-versions"
result="$(nvb_parse_tool_versions "${dir}/.tool-versions" 2>/dev/null)" || result=""
assert_empty "$result" "returns empty when no nodejs entry"

echo "nodejs v18.19.0" > "${dir}/.tool-versions"
result="$(nvb_parse_tool_versions "${dir}/.tool-versions")"
assert_eq "18.19.0" "$result" "strips v prefix in tool-versions"

teardown_fixture "$dir"

# --- Dispatch ---

echo ""
echo "Parse dispatch:"

dir="$(setup_fixture)"

echo "18.19.0" > "${dir}/.nvmrc"
result="$(nvb_parse_file ".nvmrc" "${dir}/.nvmrc")"
assert_eq "18.19.0" "$result" "dispatches .nvmrc correctly"

echo "20.0.0" > "${dir}/.node-version"
result="$(nvb_parse_file ".node-version" "${dir}/.node-version")"
assert_eq "20.0.0" "$result" "dispatches .node-version correctly"

echo "nodejs 22.0.0" > "${dir}/.tool-versions"
result="$(nvb_parse_file ".tool-versions" "${dir}/.tool-versions")"
assert_eq "22.0.0" "$result" "dispatches .tool-versions correctly"

teardown_fixture "$dir"

report
