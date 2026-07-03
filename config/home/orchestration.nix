{
  pkgs,
  lib,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  programs.ralph-tui = {
    enable = true;
    theme = "high-contrast";
  };

  ## gnhf is now managed by modules/home/ghnf.nix (programs.gnhf), which also
  ## writes its config to ~/.gnhf/config.yml.
  programs.gnhf.enable = true;

  home.packages = lib.attrValues {
    ## Spec Kit
    # spec-kit = customPkgs.spec-kit;
    ## OpenSpec CLI
    openspec = customLib.mkUvxBin pkgs "openspec" "@fission-ai/openspec@latest";
    # openspec = customPkgs.openspec;
    ## OpenSpec UI
    inherit (customPkgs) openspecui;
    ## ruflo — agent meta-harness for Claude Code & Codex (binary: ruflo).
    ## Published on npm as `ruflo`; run `ruflo init` / `ruflo mcp start`.
    ruflo = customLib.mkPnpmDlxBin pkgs "ruflo" "ruflo";
    ## Zeroshot 6.2.0 is CLI-only; the upstream TUI commands are placeholders in this release.
    zeroshot = customLib.mkPnpmDlxBin pkgs "zeroshot" "@the-open-engine/zeroshot@6.2.0";
  };
}
