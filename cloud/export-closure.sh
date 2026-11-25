#!/usr/bin/env bash
set -euo pipefail

revision=${1:?Usage: export-closure.sh REVISION core|infra OUTPUT.gz}
profile=${2:?Supply a profile}
destination=${3:?Supply an output file}
[[ $revision =~ ^[0-9a-f]{40}$ ]] || { echo "Supply a full Git commit SHA" >&2; exit 1; }
case "$profile" in
  core) package=cloud-agent-tools ;;
  infra) package=cloud-agent-tools-infra ;;
  *) echo "Choose core or infra" >&2; exit 1 ;;
esac
system=$(nix eval --impure --raw --expr builtins.currentSystem)
case "$system" in x86_64-linux|aarch64-linux) ;; *) echo "Export on the target Linux architecture" >&2; exit 1;; esac
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
nix build --option accept-flake-config false --out-link "$work/result" \
  "github:DivitMittal/ai-nixCfg/$revision#packages.$system.$package"
result=$(readlink "$work/result")
paths=$(nix-store --query --requisites "$result")
mapfile -t closure <<< "$paths"
(
  printf 'ai-nixcfg-cloud-v1 %s %s %s %s\n' "$revision" "$system" "$profile" "$result"
  nix-store --export "${closure[@]}"
) | gzip -n > "$work/closure.gz"
mv -- "$work/closure.gz" "$destination"
sha256sum -- "$destination"
