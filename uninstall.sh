#!/usr/bin/env bash
# node-version-bridge — Uninstall script
# Removes nvb files and shell hook

set -euo pipefail

NVB_INSTALL_DIR="${NVB_INSTALL_DIR:-$HOME/.local/share/nvb}"

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

  if grep -qF "# node-version-bridge" "$rc_file"; then
    info "Removing hook from ${rc_file}..."
    # Remove the marker line and the source line after it
    sed -i.nvb-bak '/# node-version-bridge/d' "$rc_file"
    sed -i.nvb-bak '/source.*nvb\.\(zsh\|bash\)"/d' "$rc_file"
    rm -f "${rc_file}.nvb-bak"
    info "Hook removed."
  fi
}

remove_cache() {
  local cache_dir="${NVB_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/node-version-bridge}"
  if [[ -d "$cache_dir" ]]; then
    info "Removing cache at ${cache_dir}..."
    rm -rf "$cache_dir"
    info "Cache removed."
  fi
}

# --- Main ---

info "node-version-bridge uninstaller"
echo ""

remove_files

# Clean hooks from both shell configs
remove_hook "${ZDOTDIR:-$HOME}/.zshrc"
remove_hook "$HOME/.bashrc"

remove_cache

echo ""
info "Done! Restart your shell to complete the uninstall."
echo ""
