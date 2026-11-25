{
  lib,
  customLib,
  pkgs,
  config,
  ...
}: let
  cfg = config.programs.opencode;
in {
  programs.opencode = let
    package = customLib.mkBunxBin pkgs "opencode" "opencode-ai";
  in {
    enable = false; # Archived: not in active use.
    inherit package;
  };

  home.packages = lib.mkIf cfg.enable [
    (customLib.mkBunxBin pkgs "ocx" "ocx")
  ];
}
