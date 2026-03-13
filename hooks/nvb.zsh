#!/usr/bin/env zsh
# node-version-bridge — Zsh hook
# Source this file in your .zshrc

# Resolve nvb binary path relative to this hook file
_NVB_BIN="${0:A:h}/../bin/nvb"

_nvb_hook() {
  # Skip if directory hasn't changed (fast path)
  [[ "${_NVB_LAST_DIR:-}" == "$PWD" ]] && return
  _NVB_LAST_DIR="$PWD"
  eval "$("${_NVB_BIN}" refresh 2>/dev/null)"
}

autoload -U add-zsh-hook
add-zsh-hook chpwd _nvb_hook

# Force refresh on shell start (cache may be stale from previous session)
eval "$(NVB_FORCE_REFRESH=1 "${_NVB_BIN}" refresh 2>/dev/null)"
_NVB_LAST_DIR="$PWD"
