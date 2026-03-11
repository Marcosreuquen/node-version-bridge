# Architecture

## Overview

nvb is a pure bash tool with a layered architecture. Each layer has a single responsibility and communicates through function calls and global variables.

```
┌─────────────────────────────────────────┐
│          Shell Hook (zsh/bash)          │
│  Triggers on directory change, evals   │
│  output from nvb refresh               │
├─────────────────────────────────────────┤
│              bin/nvb CLI                │
│  Command dispatch: refresh, current,   │
│  doctor, version, help                 │
├─────────────────────────────────────────┤
│             Core Modules               │
│                                         │
│  detect.sh  → Find version files       │
│  parse.sh   → Extract & normalize      │
│  alias.sh   → Resolve aliases via API  │
│  resolve.sh → Apply priority rules     │
│  cache.sh   → Skip redundant switches  │
│  manager.sh → Generate apply commands  │
│  log.sh     → Structured logging       │
└─────────────────────────────────────────┘
```

## Execution Flow

1. **Hook fires** — `chpwd` (zsh) or `PROMPT_COMMAND` (bash) triggers on directory change
2. **Fast-path check** — if `$PWD` hasn't changed, return immediately (no fork)
3. **Detection** — walk directory tree upward looking for version files
4. **Parsing** — extract version from the found file, normalize it
5. **Alias resolution** — if the version is an alias (`lts/*`, `node`), resolve via nodejs.org API
6. **Priority resolution** — select the highest-priority valid version
7. **Cache check** — if `(cwd, version, source)` matches cache, skip
8. **Manager command** — generate eval-able command for the user's version manager
9. **Cache update** — store new state

## Key Design Decisions

### eval-based hook pattern

`nvb refresh` outputs shell commands to stdout. The hook evals this output in the user's interactive shell. This is necessary because some version managers (notably nvm) are shell functions that only exist in the interactive session — a subprocess can't call them.

### Manager-agnostic adapter pattern

Each version manager has three functions in `manager.sh`:

- Detection: is this manager available?
- Availability: can it be used?
- Apply: what command switches the version?

Adding a new manager means implementing these three functions.

### No side effects

nvb never modifies project files, never installs Node versions automatically, and never writes to the repository directory. It only reads version files and outputs commands.

## Module Reference

| Module | Key Function | Purpose |
|---|---|---|
| `detect.sh` | `nvb_detect_file` | Walk tree upward to find a file |
| `parse.sh` | `nvb_parse_file` | Dispatch to format-specific parser |
| `alias.sh` | `nvb_resolve_alias` | Resolve alias to concrete version |
| `resolve.sh` | `nvb_resolve_version` | Apply priority, set result globals |
| `cache.sh` | `nvb_cache_is_current` | Check if switch is needed |
| `manager.sh` | `nvb_adapter_apply_cmd` | Generate eval-able command |
| `log.sh` | `nvb_log` | Log to stderr at configured level |
