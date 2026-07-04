{
  pkgs,
  lib,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  ### Ralph Wiggum
  programs.ralph-tui = {
    enable = true;
    theme = "high-contrast";
  };
  programs.gnhf = {
    enable = true;
    # Align gnhf's auto-commits with this repo's Conventional Commits rule
    # (gnhf's default is "gnhf <iteration>: <summary>").
    settings.commitMessage.preset = "conventional";
  };

  home.packages = lib.attrValues {
    zeroshot = customLib.mkPnpmDlxBin pkgs "zeroshot" "@the-open-engine/zeroshot";

    ### SDD
    ## Spec Kit
    # spec-kit = customPkgs.spec-kit;
    ## OpenSpec CLI
    openspec = customLib.mkUvxBin pkgs "openspec" "@fission-ai/openspec@latest";
    # openspec = customPkgs.openspec;
    ## OpenSpec UI
    inherit (customPkgs) openspecui;

    ### Complete Orchestration
    ## ruflo — agent meta-harness for Claude Code & Codex (binary: ruflo).
    ## Published on npm as `ruflo`; run `ruflo init` / `ruflo mcp start`.
    ruflo = customLib.mkPnpmDlxBin pkgs "ruflo" "ruflo";
    ## gastown — Gas Town multi-agent workspace manager (binary: gt)
    inherit (customPkgs) gastown;
    ## mardi-gras — terminal UI for Beads issue tracking, parade-style (binary: mg)
    inherit (customPkgs) mardi-gras;
  };
}
