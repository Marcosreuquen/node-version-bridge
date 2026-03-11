# Contributing

Thanks for your interest in contributing! See the full [CONTRIBUTING.md](https://github.com/marcosreuquen/node-version-bridge/blob/main/CONTRIBUTING.md) on GitHub for detailed guidelines.

## Quick Start

```bash
git clone https://github.com/<your-username>/node-version-bridge.git
cd node-version-bridge
bash test/run.sh   # verify tests pass
```

## Code Style

- Bash ≥ 4.0, POSIX-compatible where possible
- `stdout` reserved for eval-able commands; logs go to `stderr`
- Must pass `shellcheck -s bash` with no warnings
- macOS compatible (no GNU-specific flags)

## Testing

```bash
bash test/run.sh
```

All tests are pure bash with no external dependencies.

## Pull Requests

1. All tests pass
2. ShellCheck passes
3. CHANGELOG.md updated
4. Clear description of what changed and why

## Reporting Issues

Include:

- OS and bash version (`bash --version`)
- Version manager and version
- Steps to reproduce
- Expected vs actual behaviour
