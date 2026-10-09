{
  pkgs,
  lib,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  isX86Darwin = pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin";
in {
  home.packages = lib.attrsets.attrValues ({
      ### Memory System (Issue Tracker)
      ## Bead. Available directly in nixpkgs-26.05-darwin (the pin already
      ## used for x86_64-darwin), unlike the rest of llm-agents.nix's
      ## packages.
      bead =
        if isX86Darwin
        then pkgs.beads
        else customPkgs.beads;
      # bead = customLib.mkPnpmDlxBin pkgs "bd" "@beads/bd";
    }
    ## Beads-Viewer. No x86_64-darwin build from llm-agents.nix, not in
    ## nixpkgs, no npm/pypi fallback. A Homebrew formula exists
    ## (`brew install beads_viewer`) but this repo has no formula-passthrough
    ## mechanism — install manually via brew on x86_64-darwin for now.
    // lib.optionalAttrs (!isX86Darwin) {Beads-Viewer = customPkgs.beads-viewer;});
}
