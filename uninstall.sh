#!/usr/bin/env bash
# node-version-bridge — Uninstall script
# Removes nvb files, shell hook, PATH entry, and optionally config/cache

set -euo pipefail

NVB_INSTALL_DIR="${NVB_INSTALL_DIR:-$HOME/.local/share/nvb}"
NVB_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvb"

info()  { echo "[nvb] $*"; }

remove_files() {
  if [[ -d "$NVB_INSTALL_DIR" ]]; then
    info "Removing ${NVB_INSTALL_DIR}..."
    rm -rf "$NVB_INSTALL_DIR"
    info "Files removed."
  else
    info "Install directory not found at ${NVB_INSTALL_DIR}, skipping."
  fi
}

remove_hook() {
  local rc_file="$1"
  [[ -f "$rc_file" ]] || return 0

  # Check if there's anything to clean
  if ! grep -qE 'node-version-bridge|nvb\.(zsh|bash)' "$rc_file" 2>/dev/null; then
    return 0
  fi

  # Remove all nvb-related lines in a single pass using a temp file
  local tmp="${rc_file}.nvb-tmp"
  grep -vE '# node-version-bridge|source.*nvb\.(zsh|bash)|\.local/share/nvb/bin' "$rc_file" > "$tmp" || true
  mv "$tmp" "$rc_file"

  info "Cleaned nvb entries from ${rc_file}."
}

remove_cache() {
  local cache_dir="${NVB_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/node-version-bridge}"
  if [[ -d "$cache_dir" ]]; then
    info "Removing cache at ${cache_dir}..."
    rm -rf "$cache_dir"
    info "Cache removed."
  fi
}

remove_config() {
  if [[ -d "$NVB_CONFIG_DIR" ]]; then
    info "Removing config at ${NVB_CONFIG_DIR}..."
    rm -rf "$NVB_CONFIG_DIR"
    info "Config removed."
  fi
}

# --- Main ---

info "node-version-bridge uninstaller"
echo ""

remove_files

# Clean hooks and PATH from both shell configs
remove_hook "${ZDOTDIR:-$HOME}/.zshrc"
remove_hook "$HOME/.bashrc"

remove_cache
remove_config

echo ""
info "Done! Restart your shell to complete the uninstall."
echo ""
