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
  ## Status Line package
  home.packages = mkIf config.programs.claude-code.enable (lib.attrsets.attrValues {
    inherit (customPkgs) ccstatusline;
  });

  programs.claude-code.settings = {
    theme = "dark";
    rendererMode = "fullscreen";
    statusLine = {
      command = "${customPkgs.ccstatusline}/bin/ccstatusline";
      padding = 0;
      type = "command";
    };
  };
}
