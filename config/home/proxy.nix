{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) optionalString;
  # --config.ignore-scripts=true prevents the postinstall from running on every dlx invocation.
  # The postinstall's validateConfiguration() hardcodes ~/.ccs/ while saveUnifiedConfig
  # respects CCS_DIR, causing a mismatch that exits 1 and kills the command.
  ccsPackage = pkgs.writeShellScriptBin "ccs" ''
    ${optionalString config.programs.ccs.useXdgConfigHome ''export CCS_DIR="${config.xdg.configHome}/ccs"''}
    exec ${pkgs.pnpm}/bin/pnpm dlx --config.ignore-scripts=true @kaitranntt/ccs "$@"
  '';
in {
  programs.ccs = {
    enable = true;
    package = ccsPackage;
    mutableUserSettings = true;
    useXdgConfigHome = true;
  };
}
