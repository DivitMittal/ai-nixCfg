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

  home.packages = lib.attrValues ({
    zeroshot = customLib.mkPnpmDlxBin pkgs "zeroshot" "@the-open-engine/zeroshot";

    ### SDD
    ## Spec Kit
    # spec-kit = customPkgs.spec-kit;
    ## OpenSpec CLI
    openspec = customLib.mkUvxBin pkgs "openspec" "@fission-ai/openspec@latest";
    # openspec = customPkgs.openspec;
    ## OpenSpec UI — npm-published; llm-agents.nix has no x86_64-darwin
    ## packages at all, so run it via pnpm dlx there instead.
    openspecui =
      if isX86Darwin
      then customLib.mkPnpmDlxBin pkgs "openspecui" "openspecui"
      else customPkgs.openspecui;

    ### Complete Orchestration
    ## ruflo — agent meta-harness for Claude Code & Codex (binary: ruflo).
    ## Published on npm as `ruflo`; run `ruflo init` / `ruflo mcp start`.
    ruflo = customLib.mkPnpmDlxBin pkgs "ruflo" "ruflo";
    ## caveman — token-compression skill/plugin installer for Claude Code and other agents.
    caveman = customLib.mkPnpmDlxBin pkgs "caveman" "github:JuliusBrussee/caveman";
  }
  ## gastown — Gas Town multi-agent workspace manager (binary: gt). Go binary
  ## with native runtime deps (dolt, sqlite, tmux, icu); llm-agents.nix has no
  ## x86_64-darwin build and there's no npm/pypi fallback. A Homebrew formula
  ## exists (`brew install gastown`) but this repo has no formula-passthrough
  ## mechanism (only `pkgs.brewCasks` for GUI casks) — install manually via
  ## brew on x86_64-darwin for now.
  // lib.optionalAttrs (!isX86Darwin) {inherit (customPkgs) gastown;}
  ## mardi-gras — terminal UI for Beads issue tracking, parade-style (binary:
  ## mg). Same story as gastown: Go binary, no x86_64-darwin build, no npm/
  ## pypi/brew fallback.
  // lib.optionalAttrs (!isX86Darwin) {inherit (customPkgs) mardi-gras;});
}
