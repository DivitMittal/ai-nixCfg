{
  pkgs,
  lib,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  isX86Darwin = pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin";
in {
  home.packages = lib.attrsets.attrValues {
    ### Memory System (Issue Tracker)
    ## Bead. Available directly in nixpkgs-26.05-darwin (the pin already
    ## used for x86_64-darwin), unlike the rest of llm-agents.nix's
    ## packages.
    bead =
      if isX86Darwin
      then pkgs.beads
      else customPkgs.beads;
    # bead = customLib.mkPnpmDlxBin pkgs "bd" "@beads/bd";
    ## Beads-Viewer (binary: bv). No x86_64-darwin build from llm-agents.nix,
    ## not in nixpkgs, no npm/pypi fallback. Has a Homebrew formula
    ## (`beads_viewer`; verified against formulae.brew.sh), so run it
    ## ephemerally via zerobrew's zbx there instead of a full brew install —
    ## the zbx tier of the bunx>pnpmx>uvx>zbx>brew fallback cascade.
    Beads-Viewer =
      if isX86Darwin
      then customLib.mkZbxBin pkgs customPkgs.zerobrew-bin "beads_viewer" "bv"
      else customPkgs.beads-viewer;
  };
}
