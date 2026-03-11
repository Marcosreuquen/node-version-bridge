# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-11

### Added

- **CLI entrypoint** (`bin/nvb`) with commands: `refresh`, `current`, `doctor`, `version`, `help`.
- **Version file detection**: walks directory tree upward to find `.nvmrc`, `.node-version`, `.tool-versions`.
- **Parser** for all three file formats with version normalization (strips `v` prefix, validates semver-like pattern).
- **Priority resolution**: configurable file priority via `NVB_PRIORITY` env var (default: `.nvmrc,.node-version,.tool-versions`).
- **Multi-manager support**: adapters for nvm, fnm, mise, asdf, and n. Auto-detection or explicit via `NVB_MANAGER`.
- **Shell hooks**: Zsh (`chpwd`) and Bash (`PROMPT_COMMAND`) with fast-path skip when directory hasn't changed.
- **Cache system**: file-based cache avoids redundant version switches when cwd/version/source are unchanged.
- **Logging**: configurable log levels (error, warn, info, debug) via `NVB_LOG_LEVEL`, all output to stderr.
- **Diagnostics**: `nvb doctor` command to inspect available managers, version files, and configuration.
- **Install/uninstall scripts**: `install.sh` copies to `~/.local/share/nvb/` and auto-configures shell hook; `uninstall.sh` cleans everything up.
- **Test suite**: 40 tests covering parsing, detection, resolution, and cache logic. Pure bash, no external dependencies.
- **Documentation**: AGENTS.md for AI agents, updated concept/design/roadmap docs.
