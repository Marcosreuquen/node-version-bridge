#!/usr/bin/env bash
# node-version-bridge — Alias resolution
# Resolves Node.js aliases (lts/*, node, stable) to concrete versions
# using the Node.js release schedule API.

NVB_ALIAS_CACHE_TTL="${NVB_ALIAS_CACHE_TTL:-3600}" # 1 hour default
_NVB_NODE_INDEX_URL="https://nodejs.org/dist/index.json"

# Get the alias cache file path
_nvb_alias_cache_file() {
  echo "${NVB_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/node-version-bridge}/node-index.json"
}

# Fetch the Node.js version index (with caching)
_nvb_fetch_node_index() {
  local cache_file
  cache_file="$(_nvb_alias_cache_file)"

  # Check if cache is fresh
  if [[ -f "$cache_file" ]]; then
    local mtime now age
    if stat -f '%m' "$cache_file" &>/dev/null; then
      # macOS
      mtime="$(stat -f '%m' "$cache_file")"
    else
      # Linux
      mtime="$(stat -c '%Y' "$cache_file")"
    fi
    now="$(date +%s)"
    age=$(( now - mtime ))
    if (( age < NVB_ALIAS_CACHE_TTL )); then
      nvb_log debug "Using cached node index (age: ${age}s)"
      cat "$cache_file"
      return 0
    fi
  fi

  nvb_log debug "Fetching node index from ${_NVB_NODE_INDEX_URL}"

  local content
  if command -v curl &>/dev/null; then
    content="$(curl -sL --max-time 10 "$_NVB_NODE_INDEX_URL" 2>/dev/null)"
  elif command -v wget &>/dev/null; then
    content="$(wget -qO- --timeout=10 "$_NVB_NODE_INDEX_URL" 2>/dev/null)"
  else
    nvb_log warn "Neither curl nor wget available, cannot resolve aliases"
    return 1
  fi

  if [[ -z "$content" ]]; then
    nvb_log warn "Failed to fetch node index"
    # Fall back to stale cache if it exists
    if [[ -f "$cache_file" ]]; then
      nvb_log debug "Falling back to stale cache"
      cat "$cache_file"
      return 0
    fi
    return 1
  fi

  mkdir -p "$(dirname "$cache_file")"
  echo "$content" > "$cache_file"
  echo "$content"
}

# Resolve an alias to a concrete version
# Supported: lts/*, lts, lts/<codename>, node, stable, latest
nvb_resolve_alias() {
  local alias="$1"

  # Normalize
  alias="$(echo "$alias" | tr '[:upper:]' '[:lower:]')"

  local index
  index="$(_nvb_fetch_node_index)" || return 1

  local version=""

  case "$alias" in
    lts|lts/\*)
      # Latest LTS version
      version="$(_nvb_extract_latest_lts "$index")"
      ;;
    lts/*)
      # Specific LTS codename (e.g., lts/iron, lts/hydrogen)
      local codename="${alias#lts/}"
      version="$(_nvb_extract_lts_by_codename "$index" "$codename")"
      ;;
    node|stable|latest)
      # Latest current version
      version="$(_nvb_extract_latest "$index")"
      ;;
    *)
      return 1
      ;;
  esac

  if [[ -n "$version" ]]; then
    nvb_log debug "Resolved alias '${alias}' → ${version}"
    echo "$version"
    return 0
  fi

  nvb_log warn "Could not resolve alias '${alias}'"
  return 1
}

# Extract the latest LTS version from the index
_nvb_extract_latest_lts() {
  local index="$1"
  # index.json: array of objects with "version":"v22.x.x","lts":"Jod" or "lts":false
  # First entry with lts !== false is the latest LTS
  echo "$index" | grep -o '"version":"v[^"]*","date":"[^"]*","files":\[[^]]*\],"npm":"[^"]*","v8":"[^"]*","uv":"[^"]*","zlib":"[^"]*","openssl":"[^"]*","modules":"[^"]*","lts":"[^"]*"' \
    | grep '"lts":"[^f]' | head -1 | grep -o '"version":"v[^"]*"' | head -1 | sed 's/"version":"v\([^"]*\)"/\1/'
}

# Extract LTS version by codename
_nvb_extract_lts_by_codename() {
  local index="$1"
  local codename="$2"
  # Case-insensitive match on codename
  echo "$index" | grep -oi "\"version\":\"v[^\"]*\"[^}]*\"lts\":\"${codename}\"" \
    | head -1 | grep -o '"version":"v[^"]*"' | sed 's/"version":"v\([^"]*\)"/\1/'
}

# Extract the latest (current) version
_nvb_extract_latest() {
  local index="$1"
  echo "$index" | grep -o '"version":"v[^"]*"' | head -1 | sed 's/"version":"v\([^"]*\)"/\1/'
}

# Check if a string looks like a known alias
nvb_is_alias() {
  local value="$1"
  value="$(echo "$value" | tr '[:upper:]' '[:lower:]')"
  case "$value" in
    lts|lts/*|node|stable|latest) return 0 ;;
    *) return 1 ;;
  esac
}
