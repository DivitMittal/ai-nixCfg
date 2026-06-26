{
  pkgs,
  lib,
  config,
  customLib,
  ...
}: let
  inherit (lib) optionalAttrs optionalString;
  codexDlx = customLib.mkPnpmDlxBin pkgs "codex-dlx" "@openai/codex";
  codexPackage =
    (pkgs.writeShellScriptBin "codex" ''
      ${optionalString config.home.preferXdgDirectories ''export CODEX_HOME="${config.xdg.configHome}/codex"''}
      exec ${codexDlx}/bin/codex-dlx "$@"
    '')
    // (optionalAttrs config.home.preferXdgDirectories {version = "0.134.0";});
  lazycodexPackage = customLib.mkPnpmDlxBin pkgs "lazycodex" "lazycodex-ai";
in {
  programs.codex = {
    enable = true;
    mutableUserSettings = true;
    package = codexPackage;
  };

  home.packages = [lazycodexPackage];
}
