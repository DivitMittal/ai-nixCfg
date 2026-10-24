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
    enable = true;
    inherit package;
  };

  home.packages = lib.mkIf cfg.enable [
    (customLib.mkBunxBin pkgs "ocx" "ocx")
  ];
}
