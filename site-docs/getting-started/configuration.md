# Configuration

All configuration is done via environment variables. No config files needed.

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `NVB_MANAGER` | Force a specific version manager | auto-detect |
| `NVB_LOG_LEVEL` | Log level: `error`, `warn`, `info`, `debug` | `error` |
| `NVB_PRIORITY` | File priority (comma-separated) | `.nvmrc,.node-version,.tool-versions,package.json` |
| `NVB_CACHE_DIR` | Cache directory | `$XDG_CACHE_HOME/node-version-bridge` |
| `NVB_ALIAS_CACHE_TTL` | Alias cache TTL in seconds | `3600` |

## Examples

### Change file priority

Prioritize `.tool-versions` over `.nvmrc`:

```bash
export NVB_PRIORITY=".tool-versions,.nvmrc,.node-version,package.json"
```

### Force a specific manager

Always use fnm even if nvm is also available:

```bash
export NVB_MANAGER="fnm"
```

### Enable verbose logging

See exactly what nvb is doing:

```bash
export NVB_LOG_LEVEL="debug"
```

### Custom cache location

```bash
export NVB_CACHE_DIR="$HOME/.nvb-cache"
```

Add any of these to your `.zshrc` or `.bashrc` to make them permanent.
