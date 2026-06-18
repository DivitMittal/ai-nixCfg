---
description: flake-parts modules context for formatters, checks, devshells, and CI actions
applyTo: "flake/**"
---

## Overview

`flake.nix` uses `customLib.scanPaths` to auto-import every `.nix` file in `flake/`. Adding a file here is enough — no explicit import needed.

## Files

| File | Purpose |
|------|---------|
| `formatters.nix` | alejandra, deadnix, statix, prettier |
| `checks.nix` | pre-commit hooks (trim whitespace, large-file guard, merge-conflict detection) |
| `devshells.nix` | devshell with nixd, alejandra, nvfetcher, apm-cli |
| `actions/` | GitHub Actions workflows via actions-nix |

## GitHub Actions

Do NOT hand-edit `.github/workflows/` files directly. Workflows are generated — render them via:

```bash
nix run .#render-workflows
```

CI triggers on pushes and PRs to `main` that touch `flake.nix`, `flake.lock`, or any file under `flake/`.

## Conventions

- All formatters and checks are declared here; do not configure them elsewhere.
- Pre-commit hooks run automatically in `nix develop`; keep them fast.
- When adding a new formatter or checker, add it to both `formatters.nix` and `checks.nix` so CI and local dev stay in sync.
