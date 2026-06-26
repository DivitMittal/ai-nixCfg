{
  config,
  pkgs,
  lib,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  programs.n8n = {
    enable = true;
    # n8n pnpm-deps aborts with SIGABRT / file-descriptor exhaustion on Darwin;
    # skip the package there (env vars still apply via home.sessionVariables).
    package =
      if pkgs.stdenv.isDarwin
      then null
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
