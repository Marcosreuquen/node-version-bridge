# Changelog

All notable changes to this project are documented here. See the full [CHANGELOG.md](https://github.com/marcosreuquen/node-version-bridge/blob/main/CHANGELOG.md) on GitHub for the canonical version.

## [0.4.1] - 2026-03-12

### Fixed

- Install script adds `nvb` to PATH so the command works after installation.
- Install script creates a default config file at `~/.config/nvb/config`.
- Install script shows a clear summary of installed paths.
- Uninstall script reliably removes all nvb entries from shell rc files.
- Uninstall script removes config directory.
- Both scripts are idempotent.

## [0.4.0] - 2026-03-11

### Added

- Configuration file support (`~/.config/nvb/config`) with key=value format. New module `lib/config.sh`.
- CLI config management: `nvb config <list|get|set|unset|path>`.
- Auto-installation of missing Node versions via `NVB_AUTO_INSTALL=true`.
- Install command adapters for all supported managers.

### Changed

- `nvb doctor` displays auto-install status and config file path.
- `nvb help` updated with config commands and `NVB_AUTO_INSTALL` reference.

## [0.3.0] - 2026-03-11

### Added

- Documentation site with MkDocs Material and GitHub Pages deployment.
- MIT License.
- CONTRIBUTING.md.

## [0.2.1] - 2026-03-11

### Fixed

- Export `NVB_RESOLVED_VERSION` and `NVB_RESOLVED_SOURCE` to fix ShellCheck SC2034 warning.
- Fix duplicate CI job names by using OS in matrix instead of bash version label.

## [0.2.0] - 2026-03-11

### Added

- Alias resolution (`lts/*`, `lts/<codename>`, `node`, `stable`, `latest`) via nodejs.org API with local caching.
- `package.json` support: detects Node version from `engines.node` field.
- Improved error messages with actionable suggestions and URLs.
- Integration tests (15 new tests).
- GitHub Actions CI with test suite and ShellCheck.
- New module `lib/alias.sh`.

### Changed

- Default `NVB_PRIORITY` now includes `package.json`.
- Total tests: 71.

## [0.1.0] - 2026-03-11

### Added

- CLI entrypoint with commands: refresh, current, doctor, version, help.
- Version file detection for `.nvmrc`, `.node-version`, `.tool-versions`.
- Parser for all formats with version normalization.
- Configurable priority resolution via `NVB_PRIORITY`.
- Multi-manager support: nvm, fnm, mise, asdf, n.
- Shell hooks for Zsh and Bash.
- Cache system to avoid redundant switches.
- Configurable logging.
- Install/uninstall scripts.
- Test suite (40 tests).
