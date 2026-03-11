# Version Files

nvb reads existing version files from your project — no need to create new ones. It walks up the directory tree from the current directory until it finds a match.

## Supported Files

### `.nvmrc`

Used by nvm and fnm. Contains a bare version number or alias.

```
20.11.0
```

Supports: exact versions, `v`-prefix, major-only (`20`), major.minor (`20.11`), and aliases (`lts/*`, `lts/iron`, `node`, `stable`, `latest`).

### `.node-version`

Used by nodenv, fnm, n, and volta. Same format as `.nvmrc`.

```
v20.11.0
```

### `.tool-versions`

Used by asdf and mise. Multi-tool file with one tool per line.

```
nodejs 20.11.0
python 3.12.0
```

nvb looks for a `nodejs` or `node` entry and extracts the version.

### `package.json`

nvb reads the `engines.node` field.

```json
{
  "engines": {
    "node": ">=20.11.0"
  }
}
```

Supported range prefixes: `>=`, `^`, `~`. The base version is extracted from the range.

## Priority Order

Default: `.nvmrc` → `.node-version` → `.tool-versions` → `package.json`

Override with:

```bash
export NVB_PRIORITY=".tool-versions,.nvmrc,.node-version,package.json"
```

## Alias Resolution

Aliases found in version files are resolved to concrete versions via the [nodejs.org API](https://nodejs.org/dist/index.json):

| Alias | Resolves to |
|---|---|
| `lts/*` or `lts` | Latest LTS release |
| `lts/iron` | Latest release in the Iron LTS line |
| `node` or `latest` | Latest current release |
| `stable` | Latest current release |

Results are cached locally. Cache TTL is configurable via `NVB_ALIAS_CACHE_TTL` (default: 3600 seconds).

## Directory Walk

nvb searches from the current directory upward to the filesystem root. The **closest** matching file wins. This means a `.nvmrc` in a subdirectory overrides one in a parent directory.
