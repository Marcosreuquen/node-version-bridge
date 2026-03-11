# Installation

## Quick Install (recommended)

```bash
git clone https://github.com/marcosreuquen/node-version-bridge.git
cd node-version-bridge
bash install.sh
```

The script will:

1. Copy `nvb` to `~/.local/share/nvb/`
2. Automatically add the shell hook to your `.zshrc` or `.bashrc`

Then restart your shell or run:

```bash
source ~/.zshrc   # or ~/.bashrc
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

This removes installed files, the shell hook from your config, and the cache directory.

### Manual

1. Remove the `source ...nvb.zsh` (or `nvb.bash`) line from your shell config
2. Delete the install directory: `rm -rf ~/.local/share/nvb`
3. Optionally delete the cache: `rm -rf ~/.cache/node-version-bridge`

## Requirements

- **Bash** ≥ 4.0
- **Shell**: Zsh or Bash
- One of the [supported version managers](../reference/managers.md)
