#!/usr/bin/env bash
set -euo pipefail
state="$HOME/.local/state/ai-nixcfg-cloud"
bundle=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
provider=${1:?Usage: bash smoke.sh PROVIDER REVISION [OWNER/REPO]}
revision=${2:?Supply the expected revision}
export PATH="$bundle/bin:$PATH"

[[ $(cat "$bundle/revision") == "$revision" ]]
while IFS= read -r tool; do
  [[ -x "$bundle/bin/$tool" ]]
  case "$tool" in
    helm) "$bundle/bin/$tool" version --short ;;
    kubectl) "$bundle/bin/$tool" version --client ;;
    *) "$bundle/bin/$tool" --version ;;
  esac
done < "$bundle/tools"

case "$provider" in
  codex) instruction=AGENTS.md; skills=.agents/skills ;;
  claude) instruction=.claude/rules/ai-nixcfg.md; skills=.claude/skills ;;
  cursor) instruction=.cursor/rules/ai-nixcfg.mdc; skills=.cursor/skills ;;
  *) echo "Unknown provider: $provider" >&2; exit 1 ;;
esac
[[ -s "$bundle/config/$provider/$instruction" ]]
[[ -s "$bundle/config/$provider/$skills/nix-flakes/SKILL.md" ]]
[[ -s "$state/env" ]]
printf 'Verified %s at ai-nixCfg %s\n' "$provider" "$revision"

if [[ -n ${3:-} ]]; then
  [[ $3 =~ ^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$ ]]
  GH_DEBUG='' GH_PROMPT_DISABLED=1 gh auth status --hostname github.com ||
    echo 'Account-level auth status unavailable. Checking repository API access.' >&2
  GH_DEBUG='' GH_PROMPT_DISABLED=1 gh api --hostname github.com "repos/$3" --jq .full_name
fi
