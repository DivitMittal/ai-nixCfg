{
  lib,
  pkgs,
  config,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  ## GUI app casks (installed via brew-nix). They depend on the consuming host's
  ## brew-nix overlay (pkgs.brewCasks); the standalone `#ai` CLI shell disables
  ## this so it stays lean and needs no brew-nix input. Defaults on for normal
  ## (OS-nixCfg) consumption.
  options.aiNixCfg.guiApps.enable =
    lib.mkEnableOption "GUI application casks (Antigravity, Perplexity, …)"
    // {default = true;};

  config = lib.mkIf (config.aiNixCfg.guiApps.enable && pkgs.stdenv.isDarwin) {
    # Upstream home-manager provides programs.t3code (package defaults to
    # `pkgs.t3code or null`, so enabling without the package is safe).
    programs.t3code = {
      enable = true;
    };

    home.packages = lib.attrsets.attrValues {
      inherit (customPkgs) Perplexity-bin;

      handy = pkgs.brewCasks.handy.override {variation = "tahoe";};

      codex-app = pkgs.brewCasks."codex-app";

      inherit (pkgs.brewCasks) antigravity;

      ## Clean bin to avoid collision with claude-code CLI
      claude-desktop = pkgs.brewCasks.claude.overrideAttrs (oldAttrs: {
        installPhase =
          oldAttrs.installPhase
          + ''
            rm -rf $out/bin
          '';
      });
    };
  };
}
