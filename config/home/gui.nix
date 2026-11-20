{
  lib,
  pkgs,
  config,
  ...
}: {
  ## GUI app casks (installed via brew-nix). They depend on the consuming host's
  ## brew-nix overlay (pkgs.brewCasks); the standalone `#ai` CLI shell disables
  ## this so it stays lean and needs no brew-nix input.
  options.aiNixCfg.guiApps.enable =
    lib.mkEnableOption "GUI application casks (Antigravity, Perplexity, …)"
    // {default = true;};

  config = lib.mkIf (config.aiNixCfg.guiApps.enable && pkgs.stdenv.isDarwin) {
    programs.t3code = {
      enable = false;
      package = pkgs.brewCasks.t3-code;
      mutableUserSettings = true;
      mutableKeybindings = true;
      mutableClientSettings = true;
    };

    programs.antigravity = {
      enable = false;
      package = pkgs.brewCasks.antigravity;
      mutableExtensionsDir = true;
      profiles.default = {
        enableMcpIntegration = true;
      };
    };

    home.packages = lib.attrsets.attrValues {
      #inherit (customPkgs) Perplexity-bin;

      handy = pkgs.brewCasks.handy.override {variation = "tahoe";};

      ## Disabled in favor of ChatGPT on the web.
      #chatgpt = pkgs.brewCasks.chatgpt.override (
      #  lib.optionalAttrs pkgs.stdenv.hostPlatform.isx86_64 {variation = "tahoe";}
      #);

      ## Claude desktop remains disabled in favor of the web version.
      ## Clean bin to avoid collision with claude-code CLI
      #claude-desktop = pkgs.brewCasks.claude.overrideAttrs (oldAttrs: {
      #  installPhase =
      #    oldAttrs.installPhase
      #    + ''
      #      rm -rf $out/bin
      #    '';
      #});
    };
  };
}
