---
allowed-tools: Bash(nix:*), Bash(npm:*), Bash(cargo:*)
description: Build the project
---
Detect and build:
- Nix flake: `nix build`
- Nix darwin: `darwin-rebuild build --flake .`
- Node: `npm run build`
- Rust: `cargo build`

Report success or errors.
