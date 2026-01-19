{
  pkgs,
  lib,
  config,
  ai-nixCfg,
  ...
}: let
  inherit (lib) mkIf;
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  imports = lib.custom.scanPaths ./.;

  home.packages = mkIf config.programs.codex.enable (lib.attrsets.attrValues {
    inherit (customPkgs) ccusage-codex;
  });

  programs.codex = {
    enable = true;
    package = customPkgs.codex;
  };
}
