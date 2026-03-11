# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-07-18

### Added

- **Alias resolution**: `lts/*`, `lts/<codename>`, `node`, `stable`, `latest` aliases are now resolved to concrete versions via the nodejs.org API. Results are cached locally (TTL configurable via `NVB_ALIAS_CACHE_TTL`, default 1h).
- **package.json support**: Detects Node version from `engines.node` field. Handles exact versions, `v`-prefix, and semver range prefixes (`>=`, `^`, `~`).
- **Improved error messages**: Actionable suggestions with URLs when no version file or no manager is found.
- **Integration tests**: 15 new tests covering multi-directory navigation, nested project overrides, fallback chains, cache integration, and empty tree scenarios.
- **GitHub Actions CI**: Runs full test suite and ShellCheck on push/PR for both Ubuntu and macOS.
- **New module** `lib/alias.sh` for alias detection and resolution.

### Changed

- Default `NVB_PRIORITY` now includes `package.json`: `.nvmrc,.node-version,.tool-versions,package.json`.
- Version bumped to 0.2.0.
- Total test count: 71 (up from 40).

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
