{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
in {
  imports = lib.custom.scanPaths ./.;

  home.packages = mkIf config.programs.codex.enable (lib.attrsets.attrValues {
    inherit (pkgs) ccusage-codex;
  });

  programs.codex = let
    package = pkgs.codex;
  in {
    enable = true;
    inherit package;
  };
}
