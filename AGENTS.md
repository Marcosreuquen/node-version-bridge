# AGENTS.md — AI Agent Context for node-version-bridge

## Project Summary

**node-version-bridge (nvb)** is a shell-based tool that detects the Node.js version declared in a project's configuration files (`.nvmrc`, `.node-version`, `.tool-versions`, `package.json`) and automatically applies it via the user's preferred version manager. It eliminates the need to maintain duplicate version files across different tooling ecosystems.

## Architecture

```
bin/nvb              ← CLI entrypoint (bash). Parses commands, delegates to libs.
lib/
  log.sh             ← Logging to stderr. Levels: error, warn, info, debug.
  config.sh          ← Config file loading and CLI config management.
  detect.sh          ← Walks directory tree upward to find version files.
  parse.sh           ← Extracts & normalizes version from each file format.
  resolve.sh         ← Applies priority rules, selects target version.
  cache.sh           ← Avoids redundant switches (file-based cache).
  manager.sh         ← Detects version manager, generates eval-able commands.
  alias.sh           ← Resolves Node aliases (lts/*, node, stable) via nodejs.org API.
hooks/
  nvb.zsh            ← Zsh shell hook (chpwd-based).
  nvb.bash           ← Bash shell hook (PROMPT_COMMAND-based).
test/
  test_helper.sh     ← Shared assertions and fixture utilities.
  test_parse.sh      ← Parse tests for all file formats.
  test_detect.sh     ← Directory walk and file detection tests.
  test_resolve.sh    ← Priority resolution and cache tests.
  test_integration.sh ← Multi-directory, nested override, and fallback tests.
  run.sh             ← Test runner (executes all test_*.sh files).
```

## Key Design Decisions

1. **eval-based hook pattern**: `nvb refresh` outputs shell commands to stdout. The hook evals this output in the user's interactive shell. This allows the tool to work with shell functions (like `nvm`) that only exist in the interactive shell context.

2. **Manager-agnostic**: Supports nvm, fnm, mise, asdf, and n via adapter pattern in `manager.sh`. Manager is auto-detected or set via `NVB_MANAGER`.

3. **Version validation**: Parsed versions must match `^[0-9]+(\.[0-9]+)?(\.[0-9]+)?$`. Aliases (`lts/*`, `node`, `stable`) are resolved to concrete versions via the nodejs.org API (since v0.2.0).

4. **Priority system**: Default order is `.nvmrc` → `.node-version` → `.tool-versions` → `package.json`. Configurable via `NVB_PRIORITY` env var.

5. **Cache**: File at `$XDG_CACHE_HOME/node-version-bridge/state` stores last `(cwd, version, source)`. Hooks skip work when unchanged.

## Environment Variables

| Variable | Purpose | Default |
|---|---|---|
| `NVB_MANAGER` | Force version manager | auto-detect |
| `NVB_LOG_LEVEL` | Verbosity (error/warn/info/debug) | `error` |
| `NVB_PRIORITY` | File priority (comma-separated) | `.nvmrc,.node-version,.tool-versions,package.json` |
| `NVB_CACHE_DIR` | Cache directory | `$XDG_CACHE_HOME/node-version-bridge` |
| `NVB_AUTO_INSTALL` | Auto-install missing versions (true/false) | `false` |
| `NVB_ALIAS_CACHE_TTL` | Alias cache TTL in seconds | `3600` |

## CLI Commands

- `nvb setup` — Auto-configure shell hook (run once after install)
- `nvb init <shell>` — Output eval-able hook code for zsh/bash (used in shell config)
- `nvb refresh` — Output eval-able commands (for hooks)
- `nvb current` — Show resolved version and active Node
- `nvb doctor` — Diagnostic check of managers, files, config
- `nvb config` — Manage configuration (list, get, set, unset, path)
- `nvb version` — Print version
- `nvb help` — Usage info

## Testing

Run all tests: `bash test/run.sh`

Tests are pure bash (no external dependencies). They create temporary fixture directories, exercise parsing/detection/resolution logic, and clean up after themselves.

## Conventions

- **Language**: All implementation is POSIX-compatible bash (≥4.0). No external runtimes required.
- **Output discipline**: stdout is reserved for eval-able commands or user-facing display. Logs always go to stderr.
- **No side effects**: `nvb` never modifies project files and never writes to the repo directory. Auto-installation of Node versions is opt-in via `NVB_AUTO_INSTALL`.
- **macOS compatibility**: Avoids `readlink -f` and GNU-specific flags. Uses portable alternatives.

## Extending

To add a new version manager adapter:
1. Add detection logic in `nvb_detect_manager()` in `lib/manager.sh`
2. Add availability check in `nvb_adapter_available()`
3. Add eval-able apply command in `nvb_adapter_apply_cmd()`
4. Add eval-able install command in `nvb_adapter_install_cmd()`
5. Add the manager to the `managers` array in `nvb_cmd_doctor()`

To add a new version file format:
1. Add parser function in `lib/parse.sh`
2. Add case branch in `nvb_parse_file()`
3. Include filename in default `NVB_PRIORITY`

## Versioning & Releases

The project follows [Semantic Versioning](https://semver.org/) and uses [Keep a Changelog](https://keepachangelog.com/) format.

### Version sources (must stay in sync)

All five locations below **must** show the same version before pushing to `main`. The CI `version-check` job enforces this.

| # | File | What to update | How to find it |
|---|---|---|---|
| 1 | `package.json` | `"version": "X.Y.Z"` | Top-level `version` field |
| 2 | `bin/nvb` | `NVB_VERSION="X.Y.Z"` | Line ~8 |
| 3 | `CHANGELOG.md` | `## [X.Y.Z] - YYYY-MM-DD` | New section at top, below `# Changelog` |
| 4 | `README.md` | `vX.Y.Z — …` | Last line (status footer) |
| 5 | `site-docs/development/changelog.md` | `## [X.Y.Z] - YYYY-MM-DD` | Abbreviated mirror of CHANGELOG.md |

### Release checklist (manual steps before pushing)

1. Bump version string in `package.json` (`"version"`).
2. Bump `NVB_VERSION` in `bin/nvb`.
3. Add a new `## [X.Y.Z] - YYYY-MM-DD` section in `CHANGELOG.md` with user-facing entries.
4. Add matching abbreviated section in `site-docs/development/changelog.md`.
5. Update the status line at the bottom of `README.md` to `vX.Y.Z`.
6. Run `.githooks/pre-commit` (ShellCheck + full test suite) and confirm it passes.
7. Commit and push to `main`. The release pipeline handles npm publish, git tag, and GitHub Release.

### Release pipeline

The release workflow (`.github/workflows/release.yml`) runs on push to `main` and:

1. **version-check**: Verifies all 5 version sources match, confirms the version is higher than the latest git tag, and checks if the version already exists on npm.
2. **ci**: Runs the full test suite and ShellCheck via reusable workflow (`.github/workflows/ci.yml`).
3. **publish-npm**: Publishes to npm with provenance (skipped if version already on registry).
4. **create-tag**: Creates a git tag `vX.Y.Z`.
5. **create-release**: Creates a GitHub Release from the tag with auto-generated notes.

### Changelog conventions

- Each version gets a `## [X.Y.Z] - YYYY-MM-DD` header.
- Sections: `### Added`, `### Changed`, `### Fixed`, `### Removed`.
- Entries should be concise and user-facing (what changed, not how).

## Distribution

- **npm**: Published as `node-version-bridge` (unscoped) on npmjs.com. Installs `nvb` binary globally.
- **GitHub Releases**: Tarballs attached to each release tag.
- **From source**: Clone + `bash install.sh` copies to `~/.local/share/nvb/`.
