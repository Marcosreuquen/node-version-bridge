#!/usr/bin/env bash
# node-version-bridge — Integration tests
# End-to-end scenarios testing the full resolution pipeline

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_helper.sh"

echo "=== Integration Tests ==="

echo ""
echo "Multi-directory navigation:"

# Simulate navigating between projects with different version files
root="$(setup_fixture)"
mkdir -p "${root}/project-a" "${root}/project-b" "${root}/project-c" "${root}/project-d"

echo "18.19.0" > "${root}/project-a/.nvmrc"
echo "20.11.0" > "${root}/project-b/.node-version"
echo "nodejs 22.0.0" > "${root}/project-c/.tool-versions"
cat > "${root}/project-d/package.json" << 'PJSON'
{"name":"project-d","engines":{"node":">=21.0.0"}}
PJSON

# Navigate to project-a
nvb_resolve_version "${root}/project-a" || true
assert_eq "18.19.0" "$NVB_RESOLVED_VERSION" "project-a: resolves .nvmrc"

# Navigate to project-b
nvb_resolve_version "${root}/project-b" || true
assert_eq "20.11.0" "$NVB_RESOLVED_VERSION" "project-b: resolves .node-version"

# Navigate to project-c
nvb_resolve_version "${root}/project-c" || true
assert_eq "22.0.0" "$NVB_RESOLVED_VERSION" "project-c: resolves .tool-versions"

# Navigate to project-d
nvb_resolve_version "${root}/project-d" || true
assert_eq "21.0.0" "$NVB_RESOLVED_VERSION" "project-d: resolves package.json engines.node"

# Navigate back to project-a
nvb_resolve_version "${root}/project-a" || true
assert_eq "18.19.0" "$NVB_RESOLVED_VERSION" "back to project-a: still resolves correctly"

teardown_fixture "$root"

echo ""
echo "Nested project override:"

# Child project overrides parent version
root="$(setup_fixture)"
mkdir -p "${root}/org/monorepo/packages/app"

echo "18.0.0" > "${root}/org/.nvmrc"
echo "20.0.0" > "${root}/org/monorepo/.nvmrc"
echo "22.0.0" > "${root}/org/monorepo/packages/app/.node-version"

# At app level — finds .node-version in current, not .nvmrc in parents
# But default priority is .nvmrc first, so it walks up for .nvmrc first
nvb_resolve_version "${root}/org/monorepo/packages/app" || true
assert_eq "20.0.0" "$NVB_RESOLVED_VERSION" "finds closest .nvmrc from parent (priority wins)"

# With custom priority favoring .node-version
NVB_PRIORITY=".node-version,.nvmrc,.tool-versions" \
  nvb_resolve_version "${root}/org/monorepo/packages/app" || true
assert_eq "22.0.0" "$NVB_RESOLVED_VERSION" "custom priority: .node-version in current dir wins"

teardown_fixture "$root"

echo ""
echo "Fallback chain:"

# Only package.json available — should be picked up as last resort
root="$(setup_fixture)"
mkdir -p "${root}/project"
cat > "${root}/project/package.json" << 'PJSON'
{"name":"fallback","engines":{"node":"^20.0.0"}}
PJSON

nvb_resolve_version "${root}/project" || true
assert_eq "20.0.0" "$NVB_RESOLVED_VERSION" "falls back to package.json when no other files"
assert_eq "${root}/project/package.json" "$NVB_RESOLVED_SOURCE" "source is package.json"

teardown_fixture "$root"

echo ""
echo "Empty/invalid files skipped:"

root="$(setup_fixture)"
mkdir -p "${root}/project"

# Empty .nvmrc, valid .node-version — should skip empty and use next
echo "" > "${root}/project/.nvmrc"
echo "20.0.0" > "${root}/project/.node-version"

nvb_resolve_version "${root}/project" || true
assert_eq "20.0.0" "$NVB_RESOLVED_VERSION" "skips empty .nvmrc, uses .node-version"

teardown_fixture "$root"

echo ""
echo "Cache integration:"

root="$(setup_fixture)"
export NVB_CACHE_DIR="${root}/cache"

mkdir -p "${root}/project"
echo "18.19.0" > "${root}/project/.nvmrc"

# First resolution — cache miss
nvb_resolve_version "${root}/project" || true
nvb_cache_update "${root}/project" "$NVB_RESOLVED_VERSION" "$NVB_RESOLVED_SOURCE"

# Same context — cache hit
nvb_cache_is_current "${root}/project" "18.19.0" "${root}/project/.nvmrc"
result=$?
assert_eq "0" "$result" "cache hit for same project"

# Different project — cache miss
result="false"
nvb_cache_is_current "${root}/other" "18.19.0" "${root}/project/.nvmrc" || result="true"
assert_eq "true" "$result" "cache miss for different project"

# Version changes — cache miss
echo "20.0.0" > "${root}/project/.nvmrc"
nvb_resolve_version "${root}/project" || true
result="false"
nvb_cache_is_current "${root}/project" "20.0.0" "${root}/project/.nvmrc" || result="true"
assert_eq "true" "$result" "cache miss after version file change"

unset NVB_CACHE_DIR
teardown_fixture "$root"

echo ""
echo "No version files anywhere:"

root="$(setup_fixture)"
mkdir -p "${root}/empty-project/src"

nvb_resolve_version "${root}/empty-project/src" || true
assert_empty "${NVB_RESOLVED_VERSION:-}" "no resolution in empty tree"
assert_empty "${NVB_RESOLVED_SOURCE:-}" "no source in empty tree"

teardown_fixture "$root"

report
