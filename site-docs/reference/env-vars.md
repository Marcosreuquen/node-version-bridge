# Environment Variables

Complete reference of all environment variables used by nvb.

All variables can also be set in the [config file](../getting-started/configuration.md#config-file) (`~/.config/nvb/config`). Environment variables always take precedence over config file values.

## `NVB_MANAGER`

Force a specific version manager instead of auto-detection.

- **Values**: `nvm`, `fnm`, `mise`, `asdf`, `n`
- **Default**: auto-detect (first available in order: nvm → fnm → mise → asdf → n)

```bash
export NVB_MANAGER="fnm"
```

## `NVB_LOG_LEVEL`

Controls the verbosity of log output (sent to stderr).

- **Values**: `error`, `warn`, `info`, `debug`
- **Default**: `error`

| Level | Shows |
|---|---|
| `error` | Errors that prevent operation |
| `warn` | Degraded situations (failed parse, missing file) |
| `info` | Version switches applied |
| `debug` | Full detail: search paths, cache hits, resolution steps |

```bash
export NVB_LOG_LEVEL="debug"
```

## `NVB_PRIORITY`

Comma-separated list of version files in priority order. The first file found wins.

- **Default**: `.nvmrc,.node-version,.tool-versions,package.json`

```bash
export NVB_PRIORITY=".tool-versions,.nvmrc,.node-version,package.json"
```

## `NVB_CACHE_DIR`

Directory where nvb stores its state cache.

- **Default**: `$XDG_CACHE_HOME/node-version-bridge` (falls back to `~/.cache/node-version-bridge`)

```bash
export NVB_CACHE_DIR="$HOME/.nvb-cache"
```

## `NVB_AUTO_INSTALL`

When set to `true`, nvb will automatically install a missing Node version before switching to it. The install command depends on the detected version manager.

- **Values**: `true`, `false`
- **Default**: `false`

```bash
export NVB_AUTO_INSTALL="true"
```

Or via config:

```bash
nvb config set NVB_AUTO_INSTALL true
```

## `NVB_ALIAS_CACHE_TTL`

Time-to-live in seconds for the alias resolution cache (nodejs.org API responses).

- **Default**: `3600` (1 hour)

```bash
export NVB_ALIAS_CACHE_TTL="7200"  # 2 hours
```
