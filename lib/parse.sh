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

  # Aliases not supported in v1
  case "$content" in
    lts/*|lts|node|stable|latest)
      nvb_log warn "Alias '${content}' in ${filepath} is not supported yet"
      return 1
      ;;
  esac

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
