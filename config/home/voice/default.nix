{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.aiNixCfg.voice;
  hasBrewCasks = pkgs ? brewCasks;
  hasTalonCask = hasBrewCasks && pkgs.brewCasks ? talon;
  talonPackage = pkgs.brewCasks.talon.overrideAttrs (_: {
    src = pkgs.fetchurl {
      url = "https://talonvoice.com/dl/latest/talon-mac.dmg";
      hash = "sha256-QC+LSsFy2XNg47YMN1PmUr2sxAj5K3lUf5bDThrLZ70=";
    };
  });
in {
  options.aiNixCfg.voice = {
    enable =
      mkEnableOption "voice input apps and Talon configuration"
      // {default = true;};

    installTalonDarwinApp = mkOption {
      type = types.bool;
      default = false;
      description = "Install the Talon macOS app through the brew-nix cask when available.";
    };

    enableTalonCommunity = mkOption {
      type = types.bool;
      default = false;
      description = "Install talon-community into Talon's user directory.";
    };
  };

  config = mkIf cfg.enable (lib.mkMerge [
    {
      warnings =
        lib.optional (cfg.installTalonDarwinApp && pkgs.stdenv.isDarwin && !hasTalonCask) ''
          aiNixCfg.voice.installTalonDarwinApp is enabled, but pkgs.brewCasks.talon is unavailable. The Talon app cask will not be installed by this Home Manager evaluation.
        ''
        ++ lib.optional (!pkgs.stdenv.isDarwin && cfg.installTalonDarwinApp) ''
          The Talon app is currently managed only through the Darwin Homebrew cask path; no Linux Nix package is configured by aiNixCfg.voice.installTalonDarwinApp.
        '';

      programs.talon = {
        enable = true;
        inherit (cfg) enableTalonCommunity;
        files."custom/ai-nixCfg.talon".source = ./talon/ai-nixCfg.talon;
      };
    }

    (mkIf (cfg.installTalonDarwinApp && pkgs.stdenv.isDarwin && hasTalonCask) {
      home.packages = [talonPackage];
    })
  ]);
}
