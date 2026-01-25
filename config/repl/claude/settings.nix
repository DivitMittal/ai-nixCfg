{
  ai-nixCfg,
  pkgs,
  lib,
  config,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  inherit (lib) mkIf;
in {
  home.packages = mkIf config.programs.claude-code.enable (lib.attrsets.attrValues {
    inherit (customPkgs) ccstatusline;
  });

  programs.claude-code.settings = {
    autoUpdate = false;
    includeCoAuthoredBy = false;
    statusLine = {
      command = "${customPkgs.ccstatusline}/bin/ccstatusline";
      padding = 0;
      type = "command";
    };
    theme = "dark";
  };
}
