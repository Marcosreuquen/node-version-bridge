#!/usr/bin/env bash
# node-version-bridge — Resolution tests

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_helper.sh"

echo "=== Resolution Tests ==="

echo ""
echo "Priority resolution:"

# Default priority: .nvmrc > .node-version > .tool-versions
dir="$(setup_fixture)"
echo "18.19.0" > "${dir}/.nvmrc"
echo "20.11.0" > "${dir}/.node-version"
echo "nodejs 22.0.0" > "${dir}/.tool-versions"

nvb_resolve_version "$dir" || true
assert_eq "18.19.0" "$NVB_RESOLVED_VERSION" ".nvmrc wins by default priority"
assert_eq "${dir}/.nvmrc" "$NVB_RESOLVED_SOURCE" "source is .nvmrc path"
teardown_fixture "$dir"

# Only .node-version present
dir="$(setup_fixture)"
echo "20.11.0" > "${dir}/.node-version"

nvb_resolve_version "$dir" || true
assert_eq "20.11.0" "$NVB_RESOLVED_VERSION" "resolves .node-version when alone"
teardown_fixture "$dir"

# Only .tool-versions present
dir="$(setup_fixture)"
echo "nodejs 22.0.0" > "${dir}/.tool-versions"

nvb_resolve_version "$dir" || true
assert_eq "22.0.0" "$NVB_RESOLVED_VERSION" "resolves .tool-versions when alone"
teardown_fixture "$dir"

# Custom priority order
dir="$(setup_fixture)"
echo "18.19.0" > "${dir}/.nvmrc"
echo "20.11.0" > "${dir}/.node-version"

NVB_PRIORITY=".node-version,.nvmrc,.tool-versions" nvb_resolve_version "$dir" || true
assert_eq "20.11.0" "$NVB_RESOLVED_VERSION" "respects custom priority (NVB_PRIORITY)"
teardown_fixture "$dir"

# No files — no resolution
dir="$(setup_fixture)"
nvb_resolve_version "$dir" || true
assert_empty "${NVB_RESOLVED_VERSION:-}" "returns empty when no version files"
teardown_fixture "$dir"

# File in parent directory
dir="$(setup_fixture)"
mkdir -p "${dir}/sub"
echo "18.19.0" > "${dir}/.nvmrc"

nvb_resolve_version "${dir}/sub" || true
assert_eq "18.19.0" "$NVB_RESOLVED_VERSION" "resolves from parent directory"
assert_eq "${dir}/.nvmrc" "$NVB_RESOLVED_SOURCE" "source is parent .nvmrc"
teardown_fixture "$dir"

echo ""
echo "Cache tests:"

dir="$(setup_fixture)"
export NVB_CACHE_DIR="${dir}/cache"

# Cache starts empty
result="false"
nvb_cache_is_current "/some/dir" "18.0.0" ".nvmrc" || result="true"
assert_eq "true" "$result" "cache miss on empty cache"

# Update cache
nvb_cache_update "/some/dir" "18.0.0" "/some/dir/.nvmrc"
nvb_cache_is_current "/some/dir" "18.0.0" "/some/dir/.nvmrc"
result=$?
assert_eq "0" "$result" "cache hit after update"

# Cache miss on different directory
result="false"
nvb_cache_is_current "/other/dir" "18.0.0" "/some/dir/.nvmrc" || result="true"
assert_eq "true" "$result" "cache miss on different directory"

# Cache miss on different version
result="false"
nvb_cache_is_current "/some/dir" "20.0.0" "/some/dir/.nvmrc" || result="true"
assert_eq "true" "$result" "cache miss on different version"

# Clear cache
nvb_cache_clear
result="false"
nvb_cache_is_current "/some/dir" "18.0.0" "/some/dir/.nvmrc" || result="true"
assert_eq "true" "$result" "cache miss after clear"

unset NVB_CACHE_DIR
teardown_fixture "$dir"

report
