{
  pkgs,
  lib,
  config,
  ai-nixCfg,
  customLib,
  ...
}: let
  inherit (lib) mkIf;
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  home.packages = mkIf config.programs.claude-code.enable (lib.attrsets.attrValues {
    inherit (customPkgs) ccusage;
    claude-code-switcher = customLib.mkPnpmDlxBin pkgs "ccs" "@kaitranntt/ccs";
  });

  programs.claude-code = {
    enable = true;
    package = customPkgs.claude-code;
  };
}
