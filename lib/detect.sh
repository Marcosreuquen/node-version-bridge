#!/usr/bin/env bash
# node-version-bridge — Version file detection
# Walks up directory tree to find version declaration files

# Find a specific file walking up from a directory
# Usage: nvb_detect_file <filename> [start_dir]
nvb_detect_file() {
  local filename="$1"
  local dir="${2:-$PWD}"

  while [[ "$dir" != "/" ]]; do
    if [[ -f "${dir}/${filename}" ]]; then
      echo "${dir}/${filename}"
      return 0
    fi
    dir="$(dirname "$dir")"
  done

  # Check filesystem root
  if [[ -f "/${filename}" ]]; then
    echo "/${filename}"
    return 0
  fi

  return 1
}
