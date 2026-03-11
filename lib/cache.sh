#!/usr/bin/env bash
# node-version-bridge — Cache management
# Avoids redundant version switches when directory/version hasn't changed

NVB_CACHE_DIR="${NVB_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/node-version-bridge}"

nvb_cache_file() {
  echo "${NVB_CACHE_DIR}/state"
}

# Check if cached state matches current context
nvb_cache_is_current() {
  local cwd="$1" version="$2" source="$3"
  local cache_file
  cache_file="$(nvb_cache_file)"

  [[ -f "$cache_file" ]] || return 1

  local cached_cwd cached_version cached_source
  cached_cwd="$(sed -n '1p' "$cache_file")"
  cached_version="$(sed -n '2p' "$cache_file")"
  cached_source="$(sed -n '3p' "$cache_file")"

  [[ "$cached_cwd" == "$cwd" && "$cached_version" == "$version" && "$cached_source" == "$source" ]]
}

# Update cache with current state
nvb_cache_update() {
  local cwd="$1" version="$2" source="$3"
  local cache_file
  cache_file="$(nvb_cache_file)"

  mkdir -p "$(dirname "$cache_file")"
  printf '%s\n%s\n%s\n' "$cwd" "$version" "$source" > "$cache_file"
}

# Clear stored cache
nvb_cache_clear() {
  local cache_file
  cache_file="$(nvb_cache_file)"
  rm -f "$cache_file"
}
