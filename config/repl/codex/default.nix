{
  pkgs,
  lib,
  config,
  self,
  ...
}: let
  inherit (lib) mkIf;
  customPkgs = self.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  imports =
    (lib.custom.scanPaths ./.)
    ++ [
      self.homeManagerModules.codex
    ];

  home.packages = mkIf config.programs.codex.enable (lib.attrsets.attrValues {
    inherit (customPkgs) ccusage-codex;
  });

  programs.codex = {
    enable = true;
    package = customPkgs.codex;
  };
}
