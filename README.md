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

### Quick install (recommended)

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
source /path/to/node-version-bridge/hooks/nvb.zsh
```

**Bash** — add to `~/.bashrc`:

```bash
source /path/to/node-version-bridge/hooks/nvb.bash
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

1. Remove the `source ...nvb.zsh` (or `nvb.bash`) line from your `.zshrc`/`.bashrc`
2. Delete the install directory: `rm -rf ~/.local/share/nvb`
3. Optional — delete the cache: `rm -rf ~/.cache/node-version-bridge`

## Usage

```bash
# Show resolved version vs active version
nvb current

# Full diagnostics
nvb doctor

# Show help
nvb help
```

## Configuration

Everything is configured via environment variables:

| Variable | Description | Default |
|---|---|---|
| `NVB_MANAGER` | Force a specific version manager | auto-detect |
| `NVB_LOG_LEVEL` | Log level: error, warn, info, debug | `error` |
| `NVB_PRIORITY` | File priority (comma-separated) | `.nvmrc,.node-version,.tool-versions,package.json` |
| `NVB_CACHE_DIR` | Cache directory | `$XDG_CACHE_HOME/node-version-bridge` |
| `NVB_ALIAS_CACHE_TTL` | Alias cache TTL in seconds | `3600` |

### Example: change priority

```bash
# Prioritize .tool-versions over .nvmrc
export NVB_PRIORITY=".tool-versions,.nvmrc,.node-version"
```

### Example: force a manager

```bash
# Always use fnm even if nvm is available
export NVB_MANAGER="fnm"
```

## Tests

```bash
bash test/run.sh
```

## Expected outcome

- Less daily friction when switching between projects.
- No need to commit manager-specific files when `.nvmrc`/`.node-version` already exists.
- Works with any popular Node version manager.

---

## Documentation

- [Product concept](./docs/concept.md)
- [Technical design](./docs/technical-design.md)
- [Roadmap](./docs/roadmap.md)
- [Implementation plan](./docs/implementation-plan.md)
- [Changelog](./CHANGELOG.md)

## Status

v0.2.0 — alias resolution, `package.json` support, integration tests, and CI. See [Changelog](./CHANGELOG.md).