{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.aiNixCfg.voice;
  hasBrewCasks = pkgs ? brewCasks;
  hasVoiceCasks = hasBrewCasks && pkgs.brewCasks ? wispr-flow && pkgs.brewCasks ? talon;
in {
  options.aiNixCfg.voice = {
    enable =
      mkEnableOption "voice input apps and Talon configuration"
      // {default = true;};

    installDarwinApps = mkOption {
      type = types.bool;
      default = pkgs.stdenv.isDarwin;
      description = "Install Darwin voice GUI apps through brew-nix casks when available.";
    };

    enableTalonCommunity = mkOption {
      type = types.bool;
      default = true;
      description = "Install talon-community into Talon's user directory.";
    };
  };

  config = mkIf cfg.enable (lib.mkMerge [
    {
      warnings =
        lib.optional (cfg.installDarwinApps && pkgs.stdenv.isDarwin && !hasVoiceCasks) ''
          aiNixCfg.voice.installDarwinApps is enabled, but pkgs.brewCasks.wispr-flow or pkgs.brewCasks.talon is unavailable. Wispr Flow and the Talon app cask will not be installed by this Home Manager evaluation.
        ''
        ++ lib.optional (!pkgs.stdenv.isDarwin && cfg.installDarwinApps) ''
          Wispr Flow is currently managed only through the Darwin Homebrew cask path; no Linux Nix package is configured by aiNixCfg.voice.
        '';

      programs.talon = {
        enable = true;
        inherit (cfg) enableTalonCommunity;
        files."custom/ai-nixCfg.talon".source = ./voice/talon/ai-nixCfg.talon;
      };
    }

    (mkIf (cfg.installDarwinApps && pkgs.stdenv.isDarwin && hasVoiceCasks) {
      home.packages = lib.attrsets.attrValues {
        wispr-flow = pkgs.brewCasks.wispr-flow;
        talon = pkgs.brewCasks.talon;
      };
    })
  ]);
}
