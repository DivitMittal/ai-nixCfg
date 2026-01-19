{
  pkgs,
  lib,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  imports = lib.custom.scanPaths ./.;

  programs.crush = {
    enable = true;
    package = customPkgs.crush;
  };
}
