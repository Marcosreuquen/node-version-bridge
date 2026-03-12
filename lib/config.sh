#!/usr/bin/env bash
# node-version-bridge — Configuration file support
# Loads and manages config from ~/.config/nvb/config

nvb_config_dir() {
  echo "${XDG_CONFIG_HOME:-$HOME/.config}/nvb"
}

nvb_config_file() {
  echo "$(nvb_config_dir)/config"
}

# Load config file (environment variables take precedence)
nvb_config_load() {
  local config_file
  config_file="$(nvb_config_file)"
  [[ -f "$config_file" ]] || return 0

  local key value
  while IFS='=' read -r key value || [[ -n "$key" ]]; do
    key="$(echo "$key" | xargs)" 2>/dev/null || continue
    [[ -z "$key" || "$key" == \#* ]] && continue
    value="$(echo "$value" | sed "s/^[\"']//;s/[\"']$//")"
    if [[ -z "${!key:-}" ]]; then
      export "$key=$value"
    fi
  done < "$config_file"
}

# Get a config value (env > file > default)
nvb_config_get() {
  local key="$1"
  local default="${2:-}"

  if [[ -n "${!key:-}" ]]; then
    echo "${!key}"
    return 0
  fi

  local config_file
  config_file="$(nvb_config_file)"
  if [[ -f "$config_file" ]]; then
    local file_value
    file_value="$(grep "^${key}=" "$config_file" 2>/dev/null | tail -1 | cut -d'=' -f2- | sed "s/^[\"']//;s/[\"']$//")"
    if [[ -n "$file_value" ]]; then
      echo "$file_value"
      return 0
    fi
  fi

  echo "$default"
}

# Set a config value in the file
nvb_config_set() {
  local key="$1"
  local value="$2"
  local config_dir config_file

  config_dir="$(nvb_config_dir)"
  config_file="$(nvb_config_file)"

  mkdir -p "$config_dir"

  if [[ -f "$config_file" ]] && grep -q "^${key}=" "$config_file" 2>/dev/null; then
    local tmp="${config_file}.tmp"
    sed "s|^${key}=.*|${key}=${value}|" "$config_file" > "$tmp" && mv "$tmp" "$config_file"
  else
    echo "${key}=${value}" >> "$config_file"
  fi
}

# Remove a config key
nvb_config_unset() {
  local key="$1"
  local config_file
  config_file="$(nvb_config_file)"
  [[ -f "$config_file" ]] || return 0

  local tmp="${config_file}.tmp"
  grep -v "^${key}=" "$config_file" > "$tmp" && mv "$tmp" "$config_file"
}

# List all config with source info
nvb_config_list() {
  local config_file
  config_file="$(nvb_config_file)"

  echo "Configuration ($(nvb_config_file)):"
  echo ""

  local keys=("NVB_MANAGER" "NVB_LOG_LEVEL" "NVB_PRIORITY" "NVB_CACHE_DIR" "NVB_ALIAS_CACHE_TTL" "NVB_AUTO_INSTALL")
  for key in "${keys[@]}"; do
    local env_val="${!key:-}"
    local file_val=""
    local effective=""
    local source=""

    if [[ -f "$config_file" ]]; then
      file_val="$(grep "^${key}=" "$config_file" 2>/dev/null | tail -1 | cut -d'=' -f2- | sed "s/^[\"']//;s/[\"']$//")" || true
    fi

    if [[ -n "$env_val" ]]; then
      effective="$env_val"
      if [[ -n "$file_val" ]]; then
        source="env (overrides file: ${file_val})"
      else
        source="env"
      fi
    elif [[ -n "$file_val" ]]; then
      effective="$file_val"
      source="config file"
    else
      effective="(default)"
      source=""
    fi

    if [[ -n "$source" ]]; then
      echo "  ${key}=${effective}  <- ${source}"
    else
      echo "  ${key}=${effective}"
    fi
  done
}