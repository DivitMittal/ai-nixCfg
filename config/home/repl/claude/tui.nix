{
  lib,
  ai-nixCfg,
  config,
  pkgs,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  inherit (lib) mkIf;
in {
  ## Theme
  programs.claude-code.settings.theme = "dark";

  ## Status Line
  home.packages = mkIf config.programs.claude-code.enable (lib.attrsets.attrValues {
    inherit (customPkgs) ccstatusline;
  });
  programs.claude-code.settings.statusLine = {
    command = "${customPkgs.ccstatusline}/bin/ccstatusline";
    padding = 0;
    type = "command";
  };
}
