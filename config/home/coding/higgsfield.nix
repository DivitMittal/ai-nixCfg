## Higgsfield AI: image/video generation, face swap, Soul identities.
##
## Kept out of the always-on context on purpose:
## - CLI (`higgsfield`/`higgs`) is on PATH everywhere; it costs no tokens.
## - Skills + the hosted MCP server ship together as one Claude Code plugin
##   from a pinned marketplace, NOT enabled globally. Opt in per project:
##     claude plugin install higgsfield@higgsfield --scope project
##   (writes enabledPlugins to that repo's .claude/settings.json).
## - The MCP server is deliberately absent from the shared programs.mcp set,
##   which would load it into every session of every assistant.
##
## One-time auth: `higgsfield auth login` (CLI) and `/mcp` → higgsfield (MCP).
{
  pkgs,
  options,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  marketplace = customPkgs.higgsfield-skills;
in {
  home.packages = [customPkgs.higgsfield-cli];

  # The marketplaces option only merges into known_marketplaces.json when
  # mutableSettings exists; older home-manager links that file read-only,
  # dropping marketplaces added via /plugin. There, register through
  # settings.json alone and let Claude Code record the marketplace itself.
  programs.claude-code =
    if options.programs.claude-code ? mutableSettings
    then {marketplaces.higgsfield = marketplace;}
    else {
      settings.extraKnownMarketplaces.higgsfield.source = {
        source = "directory";
        path = "${marketplace}";
      };
    };
}
