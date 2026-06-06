{
  pkgs,
  lib,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
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

    ### Automation
    ## n8n
    n8n = customLib.mkPnpmDlxBin pkgs "n8n" "n8n";

    ### Memory System (Issue Tracker)
    ## Bead
    bead = customPkgs.beads;
    # bead = customLib.mkPnpmDlxBin pkgs "bd" "@beads/bd";
    ## Beads-Viewer
    Beads-Viewer = customPkgs.beads-viewer;
  };
}
