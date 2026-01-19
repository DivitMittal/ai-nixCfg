---
allowed-tools: Bash(nix:*), Bash(npm:*), Bash(pytest:*), Bash(cargo:*)
description: Run project tests
---
Detect and run tests:
- Nix: `nix flake check`
- Node: `npm test`
- Python: `pytest`
- Rust: `cargo test`

Report results and any failures.
