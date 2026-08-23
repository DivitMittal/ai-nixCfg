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
      ## zeroshot — npm-published; bun x is tier 1 of the bunx>pnpmx>uvx>zbx>brew
      ## fallback cascade (faster than pnpm dlx, same effect).
      zeroshot = customLib.mkBunxBin pkgs "zeroshot" "@the-open-engine/zeroshot";

      ### SDD
      ## Spec Kit
      # spec-kit = customPkgs.spec-kit;
      ## OpenSpec CLI
      openspec = customLib.mkUvxBin pkgs "openspec" "@fission-ai/openspec@latest";
      # openspec = customPkgs.openspec;
      ## OpenSpec UI — npm-published; llm-agents.nix has no x86_64-darwin
      ## packages at all, so run it via bun x there instead.
      openspecui =
        if isX86Darwin
        then customLib.mkBunxBin pkgs "openspecui" "openspecui"
        else customPkgs.openspecui;

      ### Complete Orchestration
      ## ruflo — agent meta-harness for Claude Code & Codex (binary: ruflo).
      ## Published on npm as `ruflo`; run `ruflo init` / `ruflo mcp start`.
      ruflo = customLib.mkBunxBin pkgs "ruflo" "ruflo";
      ## caveman — token-compression skill/plugin installer for Claude Code and other agents.
      caveman = customLib.mkBunxBin pkgs "caveman" "github:JuliusBrussee/caveman";
      ## gastown — Gas Town multi-agent workspace manager. Go binary with native
      ## runtime deps (dolt, sqlite, tmux, icu); llm-agents.nix has no
      ## x86_64-darwin build and there's no npm/pypi fallback. Has a Homebrew
      ## formula (`gastown`, installing binary `gt`; verified against
      ## formulae.brew.sh), so run it ephemerally via zerobrew's zbx there
      ## instead of a full brew install — the zbx tier of the
      ## bunx>pnpmx>uvx>zbx>brew fallback cascade.
      gastown =
        if isX86Darwin
        then customLib.mkZbxBin pkgs customPkgs.zerobrew-bin "gastown" "gt"
        else customPkgs.gastown;
    }
    ## mardi-gras — terminal UI for Beads issue tracking, parade-style (binary:
    ## mg). Go binary, no x86_64-darwin build, no npm/pypi fallback, and no
    ## Homebrew formula either (checked formulae.brew.sh directly — not just
    ## asserted) — no fallback tier applies.
    // lib.optionalAttrs (!isX86Darwin) {inherit (customPkgs) mardi-gras;});
}
