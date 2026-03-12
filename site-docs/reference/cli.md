# CLI Commands

## `nvb refresh`

Detects the project's Node version and outputs eval-able shell commands to switch to it. This is what the shell hooks call automatically — you don't normally run this directly.

```bash
eval "$(nvb refresh)"
```

If no version file is found or the version is already active (cache hit), it outputs nothing.

When `NVB_AUTO_INSTALL` is `true`, the output will include an install command before the switch command if the version is not already installed.

## `nvb current`

Shows the resolved target version, the source file, the currently active Node version, and the detected version manager.

```bash
$ nvb current
node-version-bridge v0.4.0

  Active Node:    20.11.0
  Resolved:       20.11.0
  Source:         /home/user/my-project/.nvmrc
  Manager:        fnm
```

## `nvb doctor`

Runs diagnostics to verify your setup. Shows available managers, detected version files, configuration (including config file path and auto-install status), and active Node version.

```bash
$ nvb doctor
node-version-bridge v0.4.0 — diagnostics

Version managers:
  ● fnm (active)
  ✗ nvm
  ✗ mise
  ✗ asdf
  ✗ n

Version files (from /home/user/my-project):
  ✓ /home/user/my-project/.nvmrc → 20.11.0
  ✗ .node-version (not found)
  ✗ .tool-versions (not found)
  ✗ package.json (not found)

Configuration:
  NVB_MANAGER:         (auto-detect)
  NVB_LOG_LEVEL:       error
  NVB_PRIORITY:        .nvmrc,.node-version,.tool-versions,package.json
  NVB_CACHE_DIR:       /home/user/.cache/node-version-bridge
  NVB_AUTO_INSTALL:    false
  NVB_ALIAS_CACHE_TTL: 3600
  Config file:         /home/user/.config/nvb/config

Active Node: v20.11.0
```

## `nvb config`

Manage nvb configuration from the command line.

### `nvb config list`

Show all configuration keys with their effective values and sources (env, config file, or default).

```bash
$ nvb config list
Configuration (/home/user/.config/nvb/config):

  NVB_MANAGER=(default)
  NVB_LOG_LEVEL=debug  <- config file
  NVB_PRIORITY=(default)
  NVB_CACHE_DIR=(default)
  NVB_ALIAS_CACHE_TTL=(default)
  NVB_AUTO_INSTALL=true  <- config file
```

### `nvb config get <KEY>`

Get the effective value of a specific key.

```bash
$ nvb config get NVB_AUTO_INSTALL
true
```

### `nvb config set <KEY> <VALUE>`

Set a value in the config file.

```bash
$ nvb config set NVB_AUTO_INSTALL true
Set NVB_AUTO_INSTALL=true in /home/user/.config/nvb/config
```

### `nvb config unset <KEY>`

Remove a key from the config file.

```bash
$ nvb config unset NVB_MANAGER
Removed NVB_MANAGER from /home/user/.config/nvb/config
```

### `nvb config path`

Print the path to the config file.

```bash
$ nvb config path
/home/user/.config/nvb/config
```

## `nvb version`

Prints the nvb version.

```bash
$ nvb version
nvb 0.4.0
```

## `nvb help`

Shows usage information and available commands.
