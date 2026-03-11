# Supported Version Managers

nvb works with any of the following Node.js version managers. It auto-detects which one is available, or you can force one with `NVB_MANAGER`.

## Auto-detection Order

When `NVB_MANAGER` is not set, nvb checks for managers in this order and uses the first one found:

1. **nvm**
2. **fnm**
3. **mise**
4. **asdf**
5. **n**

## Manager Details

### nvm

- **Detection**: checks if `nvm` shell function exists
- **Command**: `nvm use <version>`
- **Notes**: nvm is a shell function, not a binary — this is why nvb uses the eval pattern

### fnm

- **Detection**: checks if `fnm` binary is in `$PATH`
- **Command**: `fnm use <version>`

### mise

- **Detection**: checks if `mise` binary is in `$PATH`
- **Command**: `eval "$(mise shell node@<version>)"`

### asdf

- **Detection**: checks if `asdf` command is available
- **Command**: `export ASDF_NODEJS_VERSION=<version>`
- **Notes**: uses environment variable override rather than `asdf shell` for better compatibility

### n

- **Detection**: checks if `n` binary is in `$PATH`
- **Command**: `n <version>`
- **Notes**: `n` switches the global Node version; it doesn't support per-shell versions

## Forcing a Manager

```bash
export NVB_MANAGER="fnm"
```

This skips auto-detection and always uses the specified manager.
