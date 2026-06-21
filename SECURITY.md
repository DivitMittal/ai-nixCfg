# Security Policy

## Scope

This repository contains Nix flake configurations for AI coding assistants and CLI tools. It does not run as a network service, but security issues can still arise from:

- Exposed secrets or credentials in committed files
- Unsafe shell commands or derivations that execute untrusted input
- Insecure MCP server configurations
- Compromised or malicious upstream package inputs

## Reporting a Vulnerability

Open a GitHub issue with:

- A description of the vulnerability and its impact
- Steps to reproduce or a proof-of-concept
- Any suggested mitigations

## Secrets Management

- Secrets (API keys, tokens) must use [agenix/ragenix](https://github.com/yaxitech/ragenix) — never committed in plaintext
- `.env` files are `.gitignore`d; verify before committing
- Audit file permissions on any sensitive config

## Dependency Security

Upstream inputs are pinned in `flake.lock`. To update:

```sh
nix flake update
nix flake check
```

Review the diff of `flake.lock` before committing updates to catch unexpected input changes.
