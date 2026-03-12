#!/usr/bin/env bash
# node-version-bridge — Manager detection and adapter dispatch
# Detects the active Node version manager and generates apply commands

# Check if a version is a full semver (x.y.z)
_nvb_is_full_version() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# Resolve a partial version (e.g. "18" or "18.20") to the best matching
# installed version. For managers that handle partials natively (nvm, fnm, n),
# returns the version as-is. For asdf/mise, queries installed versions.
nvb_resolve_installed_version() {
  local manager="$1"
  local version="$2"

  # Full semver doesn't need resolution
  if _nvb_is_full_version "$version"; then
    echo "$version"
    return 0
  fi

  local match=""
  case "$manager" in
    asdf)
      match="$(asdf list nodejs 2>/dev/null | tr -d ' *' | grep -E "^${version}(\.|$)" | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)"
      ;;
    mise)
      match="$(mise ls --installed node 2>/dev/null | awk '{print $2}' | grep -E "^${version}(\.|$)" | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)"
      ;;
    *)
      # nvm, fnm, n handle partial versions natively
      echo "$version"
      return 0
      ;;
  esac

  if [[ -n "$match" ]]; then
    nvb_log debug "Resolved partial version ${version} → ${match} for ${manager}"
    echo "$match"
  else
    nvb_log debug "No installed version matching ${version} for ${manager}"
    echo "$version"
  fi
}

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

# Output eval-able shell command to install a Node version
nvb_adapter_install_cmd() {
  local manager="$1"
  local version="$2"

  case "$manager" in
    nvm)
      echo "nvm install '${version}' >/dev/null 2>&1"
      ;;
    fnm)
      echo "fnm install '${version}' --log-level quiet 2>/dev/null"
      ;;
    mise)
      echo "mise install node@'${version}' >/dev/null 2>&1"
      ;;
    asdf)
      if _nvb_is_full_version "$version"; then
        echo "asdf install nodejs '${version}' >/dev/null 2>&1"
      else
        echo "asdf install nodejs \"\$(asdf latest nodejs '${version}')\" >/dev/null 2>&1"
      fi
      ;;
    n)
      echo "n '${version}' >/dev/null 2>&1"
      ;;
    *)
      nvb_log error "Unknown manager: ${manager}"
      return 1
      ;;
  esac
}
