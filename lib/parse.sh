#!/usr/bin/env bash
# node-version-bridge — Version file parsing
# Extracts and normalizes Node.js version from various file formats

# Dispatch parsing based on file type
nvb_parse_file() {
  local filename="$1"
  local filepath="$2"

  case "$(basename "$filename")" in
    .nvmrc)         nvb_parse_nvmrc "$filepath" ;;
    .node-version)  nvb_parse_node_version "$filepath" ;;
    .tool-versions) nvb_parse_tool_versions "$filepath" ;;
    package.json)   nvb_parse_package_json "$filepath" ;;
    *)
      nvb_log warn "Unknown file format: ${filename}"
      return 1
      ;;
  esac
}

# Parse .nvmrc — strips leading 'v', validates semver-like pattern
nvb_parse_nvmrc() {
  local filepath="$1"
  local content
  content="$(head -1 "$filepath" 2>/dev/null | tr -d '[:space:]')"

  [[ -z "$content" ]] && return 1

  # Strip leading 'v' or 'V'
  content="${content#v}"
  content="${content#V}"

  # Resolve aliases (lts/*, node, stable, etc.)
  if nvb_is_alias "$content"; then
    local resolved
    resolved="$(nvb_resolve_alias "$content")" || {
      nvb_log warn "Could not resolve alias '${content}' in ${filepath} (network unavailable?)"
      return 1
    }
    echo "$resolved"
    return 0
  fi

  # Accept partial or full semver: 18, 18.19, 18.19.0
  if [[ "$content" =~ ^[0-9]+(\.[0-9]+)?(\.[0-9]+)?$ ]]; then
    echo "$content"
    return 0
  fi

  nvb_log warn "Could not parse version from ${filepath}: '${content}'"
  return 1
}

# Parse .node-version — same format rules as .nvmrc
nvb_parse_node_version() {
  nvb_parse_nvmrc "$1"
}

# Parse .tool-versions — extract 'nodejs' or 'node' entry
nvb_parse_tool_versions() {
  local filepath="$1"
  local version

  version="$(grep -E '^(nodejs|node)\s+' "$filepath" 2>/dev/null | head -1 | awk '{print $2}' | tr -d '[:space:]')"

  [[ -z "$version" ]] && return 1

  version="${version#v}"
  version="${version#V}"

  if [[ "$version" =~ ^[0-9]+(\.[0-9]+)?(\.[0-9]+)?$ ]]; then
    echo "$version"
    return 0
  fi

  nvb_log warn "Could not parse nodejs version from ${filepath}: '${version}'"
  return 1
}

# Parse package.json — extract engines.node field
nvb_parse_package_json() {
  local filepath="$1"

  [[ -f "$filepath" ]] || return 1

  local engines_node
  # Extract "engines":{..."node":"<value>"...} using grep/sed (no jq dependency)
  engines_node="$(grep -o '"engines"[[:space:]]*:[[:space:]]*{[^}]*}' "$filepath" 2>/dev/null \
    | grep -o '"node"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -1 \
    | sed 's/"node"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/')"

  [[ -z "$engines_node" ]] && return 1

  nvb_log debug "Found engines.node: '${engines_node}' in ${filepath}"

  # Handle exact versions: "18.19.0", "v18.19.0", "18"
  local clean="$engines_node"
  clean="${clean#v}"
  clean="${clean#V}"

  if [[ "$clean" =~ ^[0-9]+(\.[0-9]+)?(\.[0-9]+)?$ ]]; then
    echo "$clean"
    return 0
  fi

  # Handle semver ranges: extract the base version
  # ">=18.0.0", "^18.19.0", "~18.19.0", ">=18"
  local base
  base="$(echo "$clean" | sed 's/^[^0-9]*//' | grep -oE '^[0-9]+(\.[0-9]+)?(\.[0-9]+)?')"

  if [[ -n "$base" ]]; then
    nvb_log info "Interpreted engines.node '${engines_node}' as minimum version ${base}"
    echo "$base"
    return 0
  fi

  nvb_log warn "Could not parse engines.node from ${filepath}: '${engines_node}'"
  return 1
}
