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
    ### Memory System (Issue Tracker)
    ## Bead
    bead = customPkgs.beads;
    # bead = customLib.mkPnpmDlxBin pkgs "bd" "@beads/bd";
    ## Beads-Viewer
    Beads-Viewer = customPkgs.beads-viewer;
  };
}
