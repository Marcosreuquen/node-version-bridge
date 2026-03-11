# CLI Commands

## `nvb refresh`

Detects the project's Node version and outputs eval-able shell commands to switch to it. This is what the shell hooks call automatically — you don't normally run this directly.

```bash
eval "$(nvb refresh)"
```

If no version file is found or the version is already active (cache hit), it outputs nothing.

## `nvb current`

Shows the resolved target version, the source file, the currently active Node version, and the detected version manager.

```bash
$ nvb current
Resolved version:  20.11.0
Source:            /home/user/my-project/.nvmrc
Active Node:       20.11.0
Manager:           fnm
```

## `nvb doctor`

Runs diagnostics to verify your setup.

```bash
$ nvb doctor
node-version-bridge doctor
  Version:   0.2.1
  Manager:   fnm (auto-detected)
  Priority:  .nvmrc,.node-version,.tool-versions,package.json
  Cache dir: /home/user/.cache/node-version-bridge

  Managers:
    ✓ fnm
    ✗ nvm
    ✗ mise
    ✗ asdf
    ✗ n

  Version files in current tree:
    .nvmrc → 20.11.0
```

## `nvb version`

Prints the nvb version.

```bash
$ nvb version
nvb 0.2.1
```

## `nvb help`

Shows usage information and available commands.
