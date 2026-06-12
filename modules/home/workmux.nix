{
  config,
  lib,
  pkgs,
  llm-agents,
  ...
}: let
  cfg = config.programs.workmux;
  fmt = pkgs.formats.yaml {};
in {
  options.programs.workmux = {
    enable = lib.mkEnableOption "workmux";
    settings = lib.mkOption {
      inherit (fmt) type;
      default = {};
      description = "Global workmux config written to ~/.config/workmux/config.yaml.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.workmux];
    # Force WezTerm multiplexing backend regardless of detected environment.
    home.sessionVariables.WORKMUX_BACKEND = "wezterm";
    xdg.configFile."workmux/config.yaml".source = fmt.generate "config.yaml" cfg.settings;
  };
}
