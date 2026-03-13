#!/usr/bin/env bash
# node-version-bridge — Install script
# Installs nvb to ~/.local/share/nvb, adds to PATH, configures shell hook

set -euo pipefail

NVB_INSTALL_DIR="${NVB_INSTALL_DIR:-$HOME/.local/share/nvb}"
NVB_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvb"

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

create_config() {
  if [[ -f "$NVB_CONFIG_DIR/config" ]]; then
    info "Config file already exists at ${NVB_CONFIG_DIR}/config, skipping."
    return 0
  fi

  mkdir -p "$NVB_CONFIG_DIR"
  cat > "$NVB_CONFIG_DIR/config" <<'EOF'
# node-version-bridge configuration
# Env variables override these values. See: nvb help
#
# NVB_MANAGER=
# NVB_LOG_LEVEL=error
# NVB_PRIORITY=.nvmrc,.node-version,.tool-versions,package.json
# NVB_AUTO_INSTALL=false
# NVB_ALIAS_CACHE_TTL=3600
EOF

  info "Config file created."
}

add_to_path() {
  local user_shell="$1"
  local rc_file
  rc_file="$(shell_rc_file "$user_shell")"

  local path_line="export PATH=\"${NVB_INSTALL_DIR}/bin:\$PATH\""
  local marker="# node-version-bridge:path"

  if [[ -f "$rc_file" ]] && grep -qF "$marker" "$rc_file"; then
    info "PATH entry already present in ${rc_file}, skipping."
    return 0
  fi

  info "Adding nvb to PATH in ${rc_file}..."
  {
    echo ""
    echo "$marker"
    echo "$path_line"
  } >> "$rc_file"

  info "PATH entry added."
}

add_hook() {
  local user_shell="$1"
  local rc_file
  rc_file="$(shell_rc_file "$user_shell")"

  # shellcheck disable=SC2016
  local hook_line='eval "$(nvb init '"${user_shell}"')"'
  local marker="# node-version-bridge:hook"

  if [[ -f "$rc_file" ]] && grep -qF "$marker" "$rc_file"; then
    info "Hook already present in ${rc_file}, skipping."
    return 0
  fi

  # Also check for new eval format or old source format
  if [[ -f "$rc_file" ]] && grep -qF "nvb init" "$rc_file"; then
    info "Hook already present in ${rc_file} (eval format), skipping."
    return 0
  fi
  if [[ -f "$rc_file" ]] && grep -qF "# node-version-bridge" "$rc_file" && grep -qF "nvb.${user_shell}" "$rc_file"; then
    info "Hook already present in ${rc_file} (legacy format), skipping."
    return 0
  fi

  info "Adding shell hook to ${rc_file}..."
  {
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
create_config

user_shell="$(detect_shell)"
if [[ -z "$user_shell" ]]; then
  info "Could not detect shell (zsh/bash). Add manually to your shell config:"
  echo ""
  echo "  # Add nvb to PATH"
  echo "  export PATH=\"${NVB_INSTALL_DIR}/bin:\$PATH\""
  echo ""
  echo "  # Enable auto-switching hook"
  # shellcheck disable=SC2016
  echo '  Zsh:  eval "$(nvb init zsh)"'
  # shellcheck disable=SC2016
  echo '  Bash: eval "$(nvb init bash)"'
else
  add_to_path "$user_shell"
  add_hook "$user_shell"
fi

echo ""
info "Installation complete!"
echo ""
echo "  Installed to:  ${NVB_INSTALL_DIR}"
echo "  Config file:   ${NVB_CONFIG_DIR}/config"
echo "  Binary:        ${NVB_INSTALL_DIR}/bin/nvb"
if [[ -n "$user_shell" ]]; then
  echo "  Shell config:  $(shell_rc_file "$user_shell")"
fi
echo ""
info "Restart your shell or run:"
echo ""
echo "  source $(shell_rc_file "${user_shell:-zsh}")"
echo ""
