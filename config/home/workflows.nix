{
  config,
  pkgs,
  lib,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  programs.n8n = {
    enable = true;
    # n8n pnpm-deps aborts with SIGABRT / file-descriptor exhaustion on Darwin;
    # use pnpm dlx there so the binary is still available without a native build.
    package =
      if pkgs.stdenv.isDarwin
      then customLib.mkPnpmDlxBin pkgs "n8n" "n8n"
      else pkgs.n8n;
    environment = {
      DB_TYPE = "sqlite";
      DB_SQLITE_DATABASE = "${config.xdg.stateHome}/n8n/.n8n/database.sqlite";
      N8N_DIAGNOSTICS_ENABLED = false;
      N8N_VERSION_NOTIFICATIONS_ENABLED = false;
    };
  };

  home.packages = lib.attrsets.attrValues {
    inherit (customPkgs) apm;
  };
}
