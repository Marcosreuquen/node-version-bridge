#!/usr/bin/env bash
# node-version-bridge — Bash hook
# Source this file in your .bashrc

# Resolve nvb binary path relative to this hook file
_NVB_BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)/nvb"

_nvb_hook() {
  # Skip if directory hasn't changed (fast path, avoids fork)
  [[ "${_NVB_LAST_DIR:-}" == "$PWD" ]] && return
  _NVB_LAST_DIR="$PWD"
  eval "$("${_NVB_BIN}" refresh 2>/dev/null)"
}

# Append to PROMPT_COMMAND without duplicating
if [[ ";${PROMPT_COMMAND:-};" != *";_nvb_hook;"* ]]; then
  PROMPT_COMMAND="_nvb_hook;${PROMPT_COMMAND:-}"
fi
