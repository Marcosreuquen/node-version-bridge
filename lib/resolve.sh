#!/usr/bin/env bash
# node-version-bridge — Version resolution
# Applies priority rules to select the target Node.js version

# Resolve the target version from available files
# Sets: NVB_RESOLVED_VERSION, NVB_RESOLVED_SOURCE
nvb_resolve_version() {
  local dir="${1:-$PWD}"
  local priority_str="${NVB_PRIORITY:-.nvmrc,.node-version,.tool-versions}"

  NVB_RESOLVED_VERSION=""
  NVB_RESOLVED_SOURCE=""

  IFS=',' read -ra priorities <<< "$priority_str"

  for filename in "${priorities[@]}"; do
    filename="$(echo "$filename" | xargs)" # trim whitespace
    local filepath
    filepath="$(nvb_detect_file "$filename" "$dir")" || continue

    local version
    version="$(nvb_parse_file "$filename" "$filepath")" || continue

    NVB_RESOLVED_VERSION="$version"
    NVB_RESOLVED_SOURCE="$filepath"
    nvb_log debug "Resolved ${version} from ${filepath}"
    return 0
  done

  nvb_log debug "No version file found from ${dir}"
  return 1
}
