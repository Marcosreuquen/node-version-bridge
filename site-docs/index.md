# node-version-bridge

Automatically detects the Node.js version declared in your project and applies it using your preferred version manager.

## The Problem

Many Node projects already have files like `.nvmrc` or `.node-version`, but if you use a different version manager than the rest of your team (asdf, nvm, fnm, mise, n), you end up maintaining duplicate files or running manual commands every time you switch projects.

## The Solution

`nvb` reads the version files that already exist in your project and automatically applies the correct Node version when you enter the directory — regardless of which version manager you use.

## Key Features

- **Manager-agnostic** — works with nvm, fnm, mise, asdf, and n
- **Zero config** — works out of the box with existing version files
- **Alias resolution** — `lts/*`, `lts/iron`, `node`, `stable`, `latest` resolved automatically
- **Smart caching** — skips redundant version switches
- **Multiple file formats** — `.nvmrc`, `.node-version`, `.tool-versions`, `package.json`

## Quick Start

```bash
git clone https://github.com/marcosreuquen/node-version-bridge.git
cd node-version-bridge
bash install.sh
```

Restart your shell, then enter any project with a version file:

```bash
cd my-project/    # has .nvmrc with "20.11.0"
node --version    # v20.11.0 ✓
```

See the [Installation guide](getting-started/installation.md) for more options.
