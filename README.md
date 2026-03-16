# node-version-bridge

Automatically detects the Node.js version declared in your project and applies it using your preferred version manager.

## Problem

Many Node projects already have files like `.nvmrc` or `.node-version`, but if you use a different version manager than the rest of your team (asdf, nvm, fnm, mise, n), you end up maintaining duplicate files or running manual commands every time you switch projects.

## Solution

`nvb` reads the version files that already exist in your project and automatically applies the correct Node version when you enter the directory — regardless of which version manager you use.

## Supported managers

- **nvm** — `nvm use <version>`
- **fnm** — `fnm use <version>`
- **mise** — `mise shell node@<version>`
- **asdf** — `export ASDF_NODEJS_VERSION=<version>`
- **n** — `n <version>`

## Detected version files

By default, in this priority order:

1. `.nvmrc`
2. `.node-version`
3. `.tool-versions`
4. `package.json` (`engines.node`)

Aliases like `lts/*`, `lts/iron`, `node`, `stable`, and `latest` are automatically resolved to concrete versions via the nodejs.org API.

## Installation

### npm (recommended)

```bash
npm install -g node-version-bridge
nvb setup
```

This installs the `nvb` command globally and configures the shell hook automatically.

### GitHub Releases

Download the latest release from [GitHub Releases](https://github.com/Marcosreuquen/node-version-bridge/releases), extract it, and run:

```bash
bash install.sh
```

### From source

```bash
git clone https://github.com/marcosreuquen/node-version-bridge.git
cd node-version-bridge
bash install.sh
```

The script will:
1. Copy `nvb` to `~/.local/share/nvb/`
2. Automatically add the shell hook to your `.zshrc` or `.bashrc`

Then restart your shell or run `source ~/.zshrc` (or `~/.bashrc`).

### Manual install

If you prefer full control over the installation:

```bash
git clone https://github.com/marcosreuquen/node-version-bridge.git
```

Then add the hook to your shell config:

**Zsh** — add to `~/.zshrc`:

```bash
eval "$(nvb init zsh)"
```

**Bash** — add to `~/.bashrc`:

```bash
eval "$(nvb init bash)"
```

### Verify installation

```bash
nvb doctor
```

## Uninstall

### With the script

From the repository directory:

```bash
bash uninstall.sh
```

This removes installed files, the shell hook from your config, and the cache.

### Manual

1. Remove the nvb lines from your `.zshrc`/`.bashrc` (`eval "$(nvb init ...)"` or `source ...nvb.zsh`/`nvb.bash`)
2. Delete the install directory: `rm -rf ~/.local/share/nvb`
3. Optional — delete the cache: `rm -rf ~/.cache/node-version-bridge`

## Usage

```bash
# Configure shell hook (run once after install)
nvb setup

# Show resolved version vs active version
nvb current

# Full diagnostics
nvb doctor

# Manage configuration
nvb config list
nvb config set NVB_AUTO_INSTALL true

# Show help
nvb help
```

## Configuration

Configuration can be set via environment variables or a config file at `~/.config/nvb/config` (or `$XDG_CONFIG_HOME/nvb/config`). Environment variables always take precedence over the config file.

### Config file

Create `~/.config/nvb/config` (or use `nvb config set`):

```ini
NVB_MANAGER=fnm
NVB_LOG_LEVEL=info
NVB_AUTO_INSTALL=true
```

### Manage config from the CLI

```bash
nvb config list                          # Show all config values and sources
nvb config set NVB_AUTO_INSTALL true     # Enable auto-install
nvb config set NVB_MANAGER fnm           # Force fnm
nvb config get NVB_LOG_LEVEL             # Read a value
nvb config unset NVB_MANAGER             # Remove a key
nvb config path                          # Show config file path
```

### Environment variables

| Variable | Description | Default |
|---|---|---|
| `NVB_MANAGER` | Force a specific version manager | auto-detect |
| `NVB_LOG_LEVEL` | Log level: error, warn, info, debug | `error` |
| `NVB_PRIORITY` | File priority (comma-separated) | `.nvmrc,.node-version,.tool-versions,package.json` |
| `NVB_CACHE_DIR` | Cache directory | `$XDG_CACHE_HOME/node-version-bridge` |
| `NVB_AUTO_INSTALL` | Auto-install missing Node versions: true/false | `false` |
| `NVB_ALIAS_CACHE_TTL` | Alias cache TTL in seconds | `3600` |

## Tests

```bash
bash test/run.sh
```

## Expected outcome

- Less daily friction when switching between projects.
- No need to commit manager-specific files when `.nvmrc`/`.node-version` already exists.
- Works with any popular Node version manager.

## Status

v0.6.2 — automatic shell hook setup, `nvb setup` and `nvb init` commands. See [Changelog](./CHANGELOG.md).

**[Full Documentation](https://marcosreuquen.github.io/node-version-bridge/)**