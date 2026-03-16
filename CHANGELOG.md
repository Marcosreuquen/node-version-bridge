# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.2] - 2026-03-16

### Fixed

- **Critical: nvb disappears after version switch on asdf/mise**: When installed via npm, the hook used bare `nvb` calls that went through asdf shims. After switching Node versions, the shim could no longer find `nvb`. The hook now pins the absolute path to the `nvb` binary at init time, so it survives version switches.
- **Help text executed init code**: `nvb help` used an unquoted heredoc that expanded `$(nvb init zsh)` instead of displaying it as text.

## [0.6.1] - 2026-03-13

### Fixed

- **Shell startup**: Version was not applied when opening a new shell because the file-based cache persisted across sessions. Hooks now force a cache bypass on startup so env-var-based managers (asdf, mise) always apply the correct version.
- **ShellCheck**: Added `SC2016` disable directives for intentional single-quoted eval strings in `bin/nvb` and `install.sh`.

### Added

- **Pre-commit hook**: `.githooks/pre-commit` runs ShellCheck and full test suite before each commit.

## [0.6.0] - 2026-03-12

### Added

- **`nvb setup` command**: Auto-configures the shell hook in your `.zshrc` or `.bashrc`. Run once after install — no more manual editing.
- **`nvb init <shell>` command**: Outputs eval-able hook code for zsh or bash. Used by `nvb setup` or can be added manually to shell config (`eval "$(nvb init zsh)"`).
- npm `postinstall` message prompting users to run `nvb setup`.

### Changed

- Install script (`install.sh`) now uses `eval "$(nvb init ...)"` hook format instead of `source .../hooks/nvb.zsh`.
- Updated README and documentation to recommend `nvb setup` for hook configuration.

## [0.5.0] - 2026-03-12

### Added

- **Partial version resolution**: Versions like `18` or `20.19` from `.nvmrc` are now resolved to the best matching installed version (e.g. `18.20.8`) for managers that require exact versions (asdf, mise). Managers that handle partials natively (nvm, fnm, n) are unaffected.
- `nvb current` now shows the resolution arrow (`18 → 18.20.8`) when a partial version is expanded.
- `nvb_resolve_installed_version()` function in `manager.sh` for querying installed versions.
- `_nvb_is_full_version()` helper to detect full semver versions.
- asdf install command now uses `asdf latest nodejs <prefix>` for partial versions.

### Fixed

- **asdf**: `export ASDF_NODEJS_VERSION` now receives the full installed version instead of a partial that asdf can't resolve, fixing `node -v` returning "No version is set".

## [0.4.1] - 2026-03-12

### Fixed

- **Install script**: `nvb` is now added to `PATH` via shell rc file, so the `nvb` command works out of the box after installation.
- **Install script**: Creates a default config file at `~/.config/nvb/config` with all available options documented as comments.
- **Install script**: Shows a clear summary of installed paths (binary, config, install dir, shell config) after installation.
- **Uninstall script**: Reliably removes all nvb entries (PATH export, hook source, markers) from shell rc files in a single pass.
- **Uninstall script**: Now also removes the config directory (`~/.config/nvb/`).
- Both scripts are fully idempotent — safe to run multiple times.

## [0.4.0] - 2026-03-11

### Added

- **Configuration file support**: Load settings from `~/.config/nvb/config` (or `$XDG_CONFIG_HOME/nvb/config`). Key=value format with environment variable override. New module `lib/config.sh`.
- **CLI config management**: New `nvb config` command with subcommands: `list`, `get`, `set`, `unset`, `path`. Manage configuration directly from the terminal.
- **Auto-installation**: When `NVB_AUTO_INSTALL=true`, nvb automatically installs missing Node versions via the detected manager before switching. Controlled via config file or env var.
- **New env var** `NVB_AUTO_INSTALL`: Enable/disable automatic installation of missing Node versions (default: `false`).
- **Install commands per manager**: `nvb_adapter_install_cmd()` in `manager.sh` generates eval-able install commands for each supported manager.

### Changed

- `nvb doctor` now displays `NVB_AUTO_INSTALL` status and config file path.
- `nvb help` updated with config command documentation and `NVB_AUTO_INSTALL` reference.
- Version bumped to 0.4.0.

## [0.3.0] - 2026-03-11

### Added

- **Documentation site**: Full MkDocs Material site with GitHub Pages deployment. Covers installation, configuration, CLI reference, supported managers, version files, environment variables, architecture, and contributing.
- **MIT License**.
- **CONTRIBUTING.md**: Guide for contributors with code style, testing, and PR guidelines.
- **GitHub Actions workflow** for automatic docs deployment on push to `main`.

## [0.2.1] - 2026-03-11

### Fixed

- Export `NVB_RESOLVED_VERSION` and `NVB_RESOLVED_SOURCE` in `resolve.sh` to fix ShellCheck SC2034 warning.
- Fix duplicate CI job names by using OS in matrix instead of bash version label.

## [0.2.0] - 2026-03-11

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
