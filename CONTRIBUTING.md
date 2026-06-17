# Contributing

Contributions are welcome — bug reports, fixes, and improvements to the AI tool configurations and Nix modules.

## Setup

```sh
nix develop   # enter dev shell (nixd, alejandra, nvfetcher)
```

## Guidelines

- **Nix files**: format with `alejandra` (enforced by pre-commit)
- Run `nix flake check` before submitting — CI runs the same check
- To update package sources: `pkgs-update` (runs nvfetcher against `pkgs/nvfetcher.toml`)

## Submitting Changes

1. Fork the repo and create a branch: `feat/description` or `fix/description`
1. Keep commits atomic; use [Conventional Commits](https://www.conventionalcommits.org/) format
1. Open a PR against `main` with a clear description of what and why

## Reporting Issues

Open a GitHub issue with:

- Your platform (macOS/Linux) and nixpkgs channel
- Steps to reproduce
- Expected vs actual behavior
