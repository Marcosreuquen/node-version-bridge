#!/usr/bin/env bash
# node-version-bridge — Manager detection and adapter dispatch
# Detects the active Node version manager and generates apply commands

# Detect which version manager is available
# Respects NVB_MANAGER override, otherwise auto-detects
nvb_detect_manager() {
  local manager="${NVB_MANAGER:-}"
  if [[ -n "$manager" ]]; then
    nvb_log debug "Using configured manager: ${manager}"
    echo "$manager"
    return 0
  fi

  # Auto-detect in common preference order
  if [[ -n "${NVM_DIR:-}" ]]; then nvb_log debug "Detected nvm"; echo "nvm"; return 0; fi
  if command -v fnm &>/dev/null;  then nvb_log debug "Detected fnm"; echo "fnm"; return 0; fi
  if command -v mise &>/dev/null; then nvb_log debug "Detected mise"; echo "mise"; return 0; fi
  if command -v asdf &>/dev/null; then nvb_log debug "Detected asdf"; echo "asdf"; return 0; fi
  if command -v n &>/dev/null;    then nvb_log debug "Detected n"; echo "n"; return 0; fi

  nvb_log error "No supported version manager detected"
  return 1
}

# Check if a specific manager is available
nvb_adapter_available() {
  local manager="$1"
  case "$manager" in
    nvm)  [[ -n "${NVM_DIR:-}" ]] ;;
    fnm)  command -v fnm &>/dev/null ;;
    mise) command -v mise &>/dev/null ;;
    asdf) command -v asdf &>/dev/null ;;
    n)    command -v n &>/dev/null ;;
    *)    return 1 ;;
  esac
}

# Output eval-able shell command to switch Node version
# The output is designed to be eval'd in the user's interactive shell
nvb_adapter_apply_cmd() {
  local manager="$1"
  local version="$2"

  case "$manager" in
    nvm)
      echo "nvm use '${version}' >/dev/null 2>&1 || echo '[nvb] Node ${version} not installed via nvm. Run: nvm install ${version}' >&2"
      ;;
    fnm)
      echo "fnm use '${version}' --log-level quiet 2>/dev/null || echo '[nvb] Node ${version} not installed via fnm. Run: fnm install ${version}' >&2"
      ;;
    mise)
      echo "eval \"\$(mise shell node@'${version}' 2>/dev/null)\" 2>/dev/null || echo '[nvb] Node ${version} not available via mise. Run: mise install node@${version}' >&2"
      ;;
    asdf)
      echo "export ASDF_NODEJS_VERSION='${version}'"
      ;;
    n)
      echo "n '${version}' >/dev/null 2>&1 || echo '[nvb] Node ${version} not installed via n. Run: n install ${version}' >&2"
      ;;
    *)
      nvb_log error "Unknown manager: ${manager}"
      return 1
      ;;
  esac
}
