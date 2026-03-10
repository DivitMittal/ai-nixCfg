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

  # Disable auto-updater - the settings.json `autoUpdate` flag is buggy
  # https://github.com/anthropics/claude-code/issues/9327
  home.sessionVariables.DISABLE_AUTOUPDATER = "1";

  programs.claude-code.settings = {
    enableAllProjectMcpServers = true;
    attribution = {
      commit = "";
      pr = "";
    };
    statusLine = {
      command = "${customPkgs.ccstatusline}/bin/ccstatusline";
      padding = 0;
      type = "command";
    };
    theme = "dark";
  };
}
