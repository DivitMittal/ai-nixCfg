{
  lib,
  pkgs,
  ai-nixCfg,
  config,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  inherit (lib) mkIf;
in {
  ## hermes-hud — TUI consciousness monitor for Hermes Agent
  home.packages = mkIf config.programs.hermes-agent.enable (lib.attrsets.attrValues {
    inherit (customPkgs) hermes-hud;
  });
}
