#!/usr/bin/env bash
# node-version-bridge — Install script
# Installs nvb to ~/.local/share/nvb and adds shell hook

set -euo pipefail

NVB_INSTALL_DIR="${NVB_INSTALL_DIR:-$HOME/.local/share/nvb}"

info()  { echo "[nvb] $*"; }
error() { echo "[nvb] ERROR: $*" >&2; }

detect_shell() {
  local current_shell
  current_shell="$(basename "${SHELL:-}")"
  case "$current_shell" in
    zsh)  echo "zsh" ;;
    bash) echo "bash" ;;
    *)    echo "" ;;
  esac
}

shell_rc_file() {
  case "$1" in
    zsh)  echo "${ZDOTDIR:-$HOME}/.zshrc" ;;
    bash) echo "$HOME/.bashrc" ;;
  esac
}

install_files() {
  info "Installing to ${NVB_INSTALL_DIR}..."

  mkdir -p "$NVB_INSTALL_DIR"

  # Determine source directory
  local src_dir
  src_dir="$(cd "$(dirname "$0")" && pwd)"

  # Copy project files
  cp -R "$src_dir"/bin "$NVB_INSTALL_DIR/"
  cp -R "$src_dir"/lib "$NVB_INSTALL_DIR/"
  cp -R "$src_dir"/hooks "$NVB_INSTALL_DIR/"

  chmod +x "$NVB_INSTALL_DIR/bin/nvb"

  info "Files installed."
}

add_hook() {
  local user_shell="$1"
  local rc_file
  rc_file="$(shell_rc_file "$user_shell")"

  local hook_line="source \"${NVB_INSTALL_DIR}/hooks/nvb.${user_shell}\""
  local marker="# node-version-bridge"

  if [[ -f "$rc_file" ]] && grep -qF "$marker" "$rc_file"; then
    info "Hook already present in ${rc_file}, skipping."
    return 0
  fi

  info "Adding hook to ${rc_file}..."
  {
    echo ""
    echo "$marker"
    echo "$hook_line"
  } >> "$rc_file"

  info "Hook added."
}

# --- Main ---

info "node-version-bridge installer"
echo ""

# Check we're running from the repo
if [[ ! -f "$(dirname "$0")/bin/nvb" ]]; then
  error "Run this script from the node-version-bridge directory."
  exit 1
fi

install_files

user_shell="$(detect_shell)"
if [[ -z "$user_shell" ]]; then
  info "Could not detect shell (zsh/bash). Add manually:"
  echo ""
  echo "  Zsh:  source \"${NVB_INSTALL_DIR}/hooks/nvb.zsh\"   # add to ~/.zshrc"
  echo "  Bash: source \"${NVB_INSTALL_DIR}/hooks/nvb.bash\"  # add to ~/.bashrc"
else
  add_hook "$user_shell"
fi

echo ""
info "Done! Restart your shell or run:"
echo ""
echo "  source $(shell_rc_file "${user_shell:-zsh}")"
echo ""
