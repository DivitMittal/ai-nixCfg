{
  pkgs,
  lib,
  config,
  customLib,
  ...
}: let
  inherit (lib) optionalString;
  ccsDlx = customLib.mkPnpmDlxBin pkgs "ccs-dlx" "@kaitranntt/ccs";
  ccsPackage = pkgs.writeShellScriptBin "ccs" ''
    ${optionalString config.programs.ccs.useXdgConfigHome ''export CCS_DIR="${config.xdg.configHome}/ccs"''}
    exec ${ccsDlx}/bin/ccs-dlx "$@"
  '';
in {
  programs.ccs = {
    enable = true;
    package = ccsPackage;
    mutableUserSettings = true;
    useXdgConfigHome = true;
  };
}
