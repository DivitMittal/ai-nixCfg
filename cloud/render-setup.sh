#!/usr/bin/env bash
set -euo pipefail

provider=${1:-}
revision=${2:-}
profile=${3:-core}
case "$provider" in codex|claude|cursor) ;; *) echo "Choose codex, claude, or cursor" >&2; exit 1;; esac
[[ $revision =~ ^[0-9a-f]{40}$ ]] || { echo "Supply the full Git commit SHA" >&2; exit 1; }
case "$profile" in core|infra) ;; *) echo "Choose core or infra" >&2; exit 1;; esac
if [[ $# -gt 3 ]]; then
  [[ $# == 5 && ( $4 =~ ^https://[^[:space:]]+$ || $4 == /* ) && $5 =~ ^[0-9a-f]{64}$ ]] ||
    { echo "Supply an HTTPS artifact URL or absolute path and SHA-256 digest" >&2; exit 1; }
fi

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
bootstrap=$(git -C "$repo" show "$revision:cloud/bootstrap.sh")
printf '#!/usr/bin/env bash\n# Generated from ai-nixCfg %s\nset --' "$revision"
printf ' %q' "$@"
printf '\n%s\n' "$bootstrap"
