# Contributing to node-version-bridge

Thanks for your interest in contributing! This guide will help you get started.

## Getting Started

1. Fork and clone the repository:

```bash
git clone https://github.com/<your-username>/node-version-bridge.git
cd node-version-bridge
```

2. Verify tests pass:

```bash
bash test/run.sh
```

No external dependencies are needed — everything is pure bash.

## Project Structure

```
bin/nvb          ← CLI entrypoint
lib/             ← Core modules (detect, parse, resolve, cache, manager, alias, log)
hooks/           ← Shell hooks (zsh, bash)
test/            ← Test suite
docs/            ← Documentation source
```

See [AGENTS.md](./AGENTS.md) for a detailed architecture overview.

## Making Changes

### Branching

- Create a feature branch from `main`: `git checkout -b feat/my-feature`
- For bug fixes: `git checkout -b fix/description`

### Code Style

- **Language**: Bash ≥ 4.0, POSIX-compatible where possible.
- **Output discipline**: `stdout` is reserved for eval-able commands or user-facing display. Logs go to `stderr`.
- **No side effects**: `nvb` never modifies project files or installs Node versions automatically.
- **macOS compatibility**: Avoid `readlink -f`, GNU-specific flags, and other non-portable constructs.
- **ShellCheck**: All code must pass `shellcheck -s bash` with no warnings. The CI enforces this.

### Testing

All changes should include tests. Tests are pure bash — no external frameworks needed.

```bash
# Run the full suite
bash test/run.sh
```

- **Parse tests**: `test/test_parse.sh` — for file format parsing changes.
- **Detect tests**: `test/test_detect.sh` — for directory walk and file detection.
- **Resolve tests**: `test/test_resolve.sh` — for priority resolution and cache.
- **Integration tests**: `test/test_integration.sh` — for end-to-end scenarios.

Tests create temporary fixture directories and clean up after themselves.

### Commit Messages

Use clear, conventional commit messages:

```
feat: add support for .mise.toml
fix: handle empty .nvmrc gracefully
docs: update configuration table in README
```

## Adding a New Version Manager

1. Add detection logic in `nvb_detect_manager()` in `lib/manager.sh`
2. Add availability check in `nvb_adapter_available()`
3. Add eval-able apply command in `nvb_adapter_apply_cmd()`
4. Add the manager to the `managers` array in `nvb_cmd_doctor()`
5. Add tests and update documentation

## Adding a New Version File Format

1. Add a parser function in `lib/parse.sh`
2. Add a case branch in `nvb_parse_file()`
3. Include the filename in the default `NVB_PRIORITY`
4. Add tests and update documentation

## Submitting a Pull Request

1. Make sure all tests pass: `bash test/run.sh`
2. Make sure ShellCheck passes: `shellcheck -s bash lib/*.sh bin/nvb hooks/nvb.bash`
3. Update the [CHANGELOG.md](./CHANGELOG.md) under an `## [Unreleased]` section
4. Open a PR against `main` with a clear description of what changed and why

## Reporting Issues

Open an issue on GitHub with:

- Your OS and bash version (`bash --version`)
- Your version manager and version
- Steps to reproduce the problem
- Expected vs actual behaviour

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](./LICENSE).
