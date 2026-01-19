{
  pkgs,
  lib,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  home.packages = lib.attrsets.attrValues {
    ### Spec-driven Development
    ## Spec Kit
    # spec-kit = customPkgs.spec-kit;
    ## OpenSpec CLI
    openspec = pkgs.writeShellScriptBin "openspec" ''
      exec ${pkgs.uv}/bin/uv tool run @fission-ai/openspec@latest "$@"
    '';
    # openspec = customPkgs.openspec;

    ## Ralph Wiggum
    ralph-tui = pkgs.writeShellScriptBin "ralph-tui" ''
      exec ${pkgs.pnpm}/bin/pnpm dlx ralph-tui "$@"
    '';

    ## Memory System (Issue Tracker)
    ## Bead
    bead = customPkgs.beads;
    # bead = pkgs.writeShellScriptBin "bd" ''
    #   exec ${pkgs.pnpm}/bin/pnpm dlx @beads/bd "$@"
    # '';
    ## Beads-Viewer
    Beads-Viewer = customPkgs.bv-bin;
  };
}
