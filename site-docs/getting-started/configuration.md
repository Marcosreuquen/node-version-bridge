# Configuration

Configuration can be set via environment variables, a config file, or the `nvb config` CLI command. Environment variables always take precedence over the config file.

## Config File

nvb reads settings from `~/.config/nvb/config` (or `$XDG_CONFIG_HOME/nvb/config`). The file uses a simple key=value format:

```ini
NVB_MANAGER=fnm
NVB_LOG_LEVEL=info
NVB_AUTO_INSTALL=true
NVB_PRIORITY=.nvmrc,.node-version,.tool-versions,package.json
```

Lines starting with `#` are treated as comments. Quoted values are automatically unquoted.

You can create or edit this file manually, or use the CLI:

```bash
nvb config set NVB_AUTO_INSTALL true
nvb config set NVB_MANAGER fnm
```

## CLI Config Management

```bash
nvb config list                          # Show all config values and their sources
nvb config get NVB_LOG_LEVEL             # Get a specific value
nvb config set NVB_AUTO_INSTALL true     # Set a value in the config file
nvb config unset NVB_MANAGER             # Remove a key from the config file
nvb config path                          # Show config file path
```

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `NVB_MANAGER` | Force a specific version manager | auto-detect |
| `NVB_LOG_LEVEL` | Log level: `error`, `warn`, `info`, `debug` | `error` |
| `NVB_PRIORITY` | File priority (comma-separated) | `.nvmrc,.node-version,.tool-versions,package.json` |
| `NVB_CACHE_DIR` | Cache directory | `$XDG_CACHE_HOME/node-version-bridge` |
| `NVB_AUTO_INSTALL` | Auto-install missing Node versions: `true`/`false` | `false` |
| `NVB_ALIAS_CACHE_TTL` | Alias cache TTL in seconds | `3600` |

## Auto-Installation

When `NVB_AUTO_INSTALL` is set to `true`, nvb will automatically install a missing Node version before switching to it. The install command is specific to your version manager:

| Manager | Install Command |
|---|---|
| nvm | `nvm install <version>` |
| fnm | `fnm install <version>` |
| mise | `mise install node@<version>` |
| asdf | `asdf install nodejs <version>` |
| n | `n <version>` |

Enable it:

```bash
nvb config set NVB_AUTO_INSTALL true
```

Or via environment variable:

```bash
export NVB_AUTO_INSTALL=true
```

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

Add any of these to your `.zshrc` or `.bashrc` to make them permanent, or use `nvb config set` to store them in the config file.
