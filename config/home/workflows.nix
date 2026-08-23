{
  pkgs,
  lib,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  programs.kestra.enable = true;

  home.packages = lib.attrsets.attrValues {
    inherit (customPkgs) apm;
  };
}
