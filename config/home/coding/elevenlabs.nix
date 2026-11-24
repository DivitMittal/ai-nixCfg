## ElevenLabs: speech, music, dubbing, and conversational agents.
##
## Kept out of the always-on context on purpose, same as Higgsfield:
## - CLI (`elevenlabs`) is on PATH everywhere; it costs no tokens.
##   Telemetry defaults off (ELEVENLABS_TELEMETRY=off).
## - Skills ship as the `elevenlabs-skills` package (one directory per skill).
##   They are not enabled globally. Opt in per project:
##     ln -s "$(nix build --no-link --print-out-paths .#elevenlabs-skills)/text-to-speech" .claude/skills/text-to-speech
##   Or regenerate CLI-shaped skills from the installed binary:
##     elevenlabs generate-skills
## - The hosted MCP server (https://api.elevenlabs.io/v1/mcp, OAuth) is
##   deliberately absent from the shared programs.mcp set, which would load
##   it into every session of every assistant. The same package's mcp.json
##   is the per-project connector config.
##
## One-time auth: `elevenlabs auth login` (CLI) and the MCP OAuth flow.
{
  pkgs,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  skills = customPkgs.elevenlabs-skills;
in {
  home.packages = [
    customPkgs.elevenlabs-cli
    skills
  ];
}
