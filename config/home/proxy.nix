{pkgs, ...}: let
  # --config.ignore-scripts=true prevents the postinstall from running on every dlx invocation.
  ccsPackage = pkgs.writeShellScriptBin "ccs" ''
    exec ${pkgs.pnpm}/bin/pnpm dlx --config.ignore-scripts=true @kaitranntt/ccs "$@"
  '';
in {
  programs.ccs = {
    enable = true;
    package = ccsPackage;
    mutableUserSettings = true;
    useXdgConfigHome = false;
  };
}
