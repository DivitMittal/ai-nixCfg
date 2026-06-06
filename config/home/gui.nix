{
  lib,
  pkgs,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in
  lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = lib.attrsets.attrValues (
      {
        inherit (customPkgs) Perplexity-bin;

        handy = pkgs.brewCasks.handy.override {variation = "tahoe";};

        codex-app = pkgs.brewCasks."codex-app";

        ## Clean bin to avoid collision with claude-code CLI
        claude-desktop = pkgs.brewCasks.claude.overrideAttrs (oldAttrs: {
          installPhase =
            oldAttrs.installPhase
            + ''
              rm -rf $out/bin
            '';
        });
      }
    );
  }
