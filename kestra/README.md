# Kestra Flows

Example [Kestra](https://kestra.io) flow definitions for automating
DivitMittal repos. These are content for a running Kestra server, not
Nix-managed config — the server itself is provisioned by
`modules/home/kestra.nix` (`programs.kestra`, run via podman).

## Flows

| Flow | Purpose |
|------|---------|
| `flows/nixcfg-fleet-flake-update.yaml` | Weekly `nix flake update` + PR across every `*-nixCfg` / flake repo, replacing N independent per-repo GitHub Actions cron jobs with one execution that shows fleet-wide status. |

## Deploying

```bash
kestra-server                            # from `programs.kestra`, local dev server
kestra flow validate kestra/flows/*.yaml
kestra flow namespace update divitmittal.nixcfg kestra/flows/
```

Set a `GITHUB_TOKEN` secret in the Kestra namespace (`divitmittal.nixcfg`)
with `repo` + `pull-requests: write` scope before running
`nixcfg-fleet-flake-update`.
