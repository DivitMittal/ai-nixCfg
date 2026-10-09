{
  lib,
  pkgs,
  ai-nixCfg,
  customLib,
  config,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  inherit (lib) mkIf;
in {
  ## hermes-hud — TUI consciousness monitor for Hermes Agent
  home.packages = mkIf config.programs.hermes-agent.enable (lib.attrsets.attrValues {
    # llm-agents.nix has no x86_64-darwin packages; hermes-hud isn't on PyPI
    # either, so run it via uv tool run straight from its git source there.
    hermes-hud =
      if pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin"
      then customLib.mkUvxBin pkgs "hermes-hud" "--from git+https://github.com/joeynyc/hermes-hud hermes-hud"
      else customPkgs.hermes-hud;
  });
}
