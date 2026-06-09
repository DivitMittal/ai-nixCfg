{
  pkgs,
  lib,
  config,
  ai-nixCfg,
  customLib,
  ...
}: let
  inherit (lib) optionalString;
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  ccsDlx = customLib.mkPnpmDlxBin pkgs "ccs-dlx" "@kaitranntt/ccs";
  ccsPackage = pkgs.writeShellScriptBin "ccs" ''
    ${optionalString config.programs.ccs.useXdgConfigHome ''export CCS_DIR="${config.xdg.configHome}/ccs"''}
    exec ${ccsDlx}/bin/ccs-dlx "$@"
  '';
in {
  home.packages = lib.mkIf config.programs.claude-code.enable (lib.attrsets.attrValues {
    inherit (customPkgs) ccusage agentsview entire;
  });

  programs.ccs = {
    enable = true;
    package = ccsPackage;
    mutableUserSettings = true;
    useXdgConfigHome = true;
  };
}
