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
