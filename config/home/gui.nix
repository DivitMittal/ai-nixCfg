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
      enable = true;
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

      ## ChatGPT desktop app — replaces the old codex-app, ChatGPT Atlas, and
      ## Operator casks, and adds ChatGPT Work, since they're all ChatGPT
      ## wrappers now.
      chatgpt = pkgs.brewCasks.chatgpt;

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
