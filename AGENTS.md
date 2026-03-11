# AGENTS.md — AI Agent Context for node-version-bridge

## Project Summary

**node-version-bridge (nvb)** is a shell-based tool that detects the Node.js version declared in a project's configuration files (`.nvmrc`, `.node-version`, `.tool-versions`, `package.json`) and automatically applies it via the user's preferred version manager. It eliminates the need to maintain duplicate version files across different tooling ecosystems.

## Architecture

```
bin/nvb              ← CLI entrypoint (bash). Parses commands, delegates to libs.
lib/
  log.sh             ← Logging to stderr. Levels: error, warn, info, debug.
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
| `NVB_ALIAS_CACHE_TTL` | Alias cache TTL in seconds | `3600` |

## CLI Commands

- `nvb refresh` — Output eval-able commands (for hooks)
- `nvb current` — Show resolved version and active Node
- `nvb doctor` — Diagnostic check of managers, files, config
- `nvb version` — Print version
- `nvb help` — Usage info

## Testing

Run all tests: `bash test/run.sh`

Tests are pure bash (no external dependencies). They create temporary fixture directories, exercise parsing/detection/resolution logic, and clean up after themselves.

## Conventions

- **Language**: All implementation is POSIX-compatible bash (≥4.0). No external runtimes required.
- **Output discipline**: stdout is reserved for eval-able commands or user-facing display. Logs always go to stderr.
- **No side effects**: `nvb` never modifies project files, never installs Node versions automatically, and never writes to the repo directory.
- **macOS compatibility**: Avoids `readlink -f` and GNU-specific flags. Uses portable alternatives.

## Extending

To add a new version manager adapter:
1. Add detection logic in `nvb_detect_manager()` in `lib/manager.sh`
2. Add availability check in `nvb_adapter_available()`
3. Add eval-able apply command in `nvb_adapter_apply_cmd()`
4. Add the manager to the `managers` array in `nvb_cmd_doctor()`

To add a new version file format:
1. Add parser function in `lib/parse.sh`
2. Add case branch in `nvb_parse_file()`
3. Include filename in default `NVB_PRIORITY`
