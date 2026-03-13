# Installation

## npm (recommended)

```bash
npm install -g node-version-bridge
```

This installs the `nvb` command globally. You still need to add the shell hook (see below).

## GitHub Releases

Download the latest release from [GitHub Releases](https://github.com/Marcosreuquen/node-version-bridge/releases), extract it, and run the install script:

```bash
bash install.sh
```

## Quick Install (from source)

```bash
git clone https://github.com/marcosreuquen/node-version-bridge.git
cd node-version-bridge
bash install.sh
```

The script will:

1. Copy `nvb` to `~/.local/share/nvb/`
2. Add `nvb` to your `PATH` in `.zshrc` or `.bashrc`
3. Add the auto-switching shell hook
4. Create a default config file at `~/.config/nvb/config`

Then restart your shell or run:

```bash
source ~/.zshrc   # or ~/.bashrc
```

## Shell Hook Setup

If you installed via npm or GitHub Releases, add the hook manually:

=== "Zsh"

    Add to `~/.zshrc`:

    ```bash
    source "$(npm prefix -g)/lib/node_modules/node-version-bridge/hooks/nvb.zsh"
    ```

=== "Bash"

    Add to `~/.bashrc`:

    ```bash
    source "$(npm prefix -g)/lib/node_modules/node-version-bridge/hooks/nvb.bash"
    ```

## Manual Install

If you prefer full control:

```bash
git clone https://github.com/marcosreuquen/node-version-bridge.git
```

Then add the hook to your shell config:

=== "Zsh"

    Add to `~/.zshrc`:

    ```bash
    source /path/to/node-version-bridge/hooks/nvb.zsh
    ```

=== "Bash"

    Add to `~/.bashrc`:

    ```bash
    source /path/to/node-version-bridge/hooks/nvb.bash
    ```

## Verify

```bash
nvb doctor
```

This checks for available version managers, version files in the current directory, and your configuration.

## Uninstall

### With the script

```bash
cd node-version-bridge
bash uninstall.sh
```

This removes installed files, PATH entry, shell hook, cache, and config directory.

### Manual

1. Remove the nvb lines from your `.zshrc`/`.bashrc` (PATH export and `source ...nvb.zsh`/`nvb.bash`)
2. Delete the install directory: `rm -rf ~/.local/share/nvb`
3. Delete the config: `rm -rf ~/.config/nvb`
4. Optionally delete the cache: `rm -rf ~/.cache/node-version-bridge`

## Requirements

- **Bash** ≥ 4.0
- **Shell**: Zsh or Bash
- One of the [supported version managers](../reference/managers.md)
