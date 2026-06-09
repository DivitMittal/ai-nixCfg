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
    environment = {
      DB_TYPE = "sqlite";
      DB_SQLITE_DATABASE = "${config.xdg.stateHome}/n8n/.n8n/database.sqlite";
      N8N_DIAGNOSTICS_ENABLED = false;
      N8N_VERSION_NOTIFICATIONS_ENABLED = false;
    };
  };

  home.packages = lib.attrsets.attrValues {
    ### Spec-driven Development
    ## Spec Kit
    # spec-kit = customPkgs.spec-kit;
    ## OpenSpec CLI
    openspec = customLib.mkUvxBin pkgs "openspec" "@fission-ai/openspec@latest";
    # openspec = customPkgs.openspec;

    ## Ralph Wiggum
    ralph-tui = customLib.mkPnpmDlxBin pkgs "ralph-tui" "ralph-tui";

    ## Indexing
    llm-tltdr = customLib.mkUvxBin pkgs "llm-tltdr" "--from llm-tldr tldr";

    ### Memory System (Issue Tracker)
    ## Bead
    bead = customPkgs.beads;
    # bead = customLib.mkPnpmDlxBin pkgs "bd" "@beads/bd";
    ## Beads-Viewer
    Beads-Viewer = customPkgs.beads-viewer;
  };
}
