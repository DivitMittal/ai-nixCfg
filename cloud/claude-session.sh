#!/usr/bin/env bash
set -euo pipefail

[[ ${CLAUDE_CODE_REMOTE:-} == true ]] || exit 0
: "${CLAUDE_ENV_FILE:?Claude did not supply a SessionStart environment file}"
env_file="$HOME/.local/state/ai-nixcfg-cloud/env"
[[ -r $env_file ]] || { echo "Run the ai-nixCfg cloud environment setup first." >&2; exit 1; }
printf 'source %q\n' "$env_file" >> "$CLAUDE_ENV_FILE"
