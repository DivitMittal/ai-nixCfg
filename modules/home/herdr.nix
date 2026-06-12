{
  config,
  lib,
  pkgs,
  llm-agents,
  ...
}: let
  cfg = config.programs.herdr;
  fmt = pkgs.formats.toml {};
in {
  options.programs.herdr = {
    enable = lib.mkEnableOption "herdr";
    settings = lib.mkOption {
      inherit (fmt) type;
      default = {};
      description = "Herdr config written to ~/.config/herdr/config.toml.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr];
    xdg.configFile."herdr/config.toml".source = fmt.generate "config.toml" cfg.settings;
  };
}
