{
  pkgs,
  lib,
  config,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  home.packages = lib.mkIf config.programs.claude-code.enable (lib.attrsets.attrValues {
    inherit (customPkgs) ccusage agentsview entire;
  });
}
