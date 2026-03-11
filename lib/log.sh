#!/usr/bin/env bash
# node-version-bridge — Logging utilities
# All log output goes to stderr to keep stdout clean for eval-able commands

nvb_log() {
  local level="$1"
  shift
  local configured="${NVB_LOG_LEVEL:-error}"

  local level_num configured_num
  level_num=$(_nvb_log_level_num "$level")
  configured_num=$(_nvb_log_level_num "$configured")

  if (( level_num <= configured_num )); then
    echo "[nvb:${level}] $*" >&2
  fi
}

_nvb_log_level_num() {
  case "$1" in
    error) echo 0 ;;
    warn)  echo 1 ;;
    info)  echo 2 ;;
    debug) echo 3 ;;
    *)     echo 0 ;;
  esac
}
