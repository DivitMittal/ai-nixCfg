{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types;
  cfg = config.programs.t3-code;

  jsonFormat = pkgs.formats.json {};
in {
  options.programs.t3-code = {
    enable = lib.mkEnableOption "T3 Code — minimal web GUI for coding agents";

    package = lib.mkOption {
      type = types.nullOr types.package;
      default = null;
      description = ''
        The T3 Code package to install.
        Set to null (the default) to skip package installation while still managing settings.
      '';
    };

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = {};
      example = lib.literalExpression ''
        {
          providers = [
            {
              name = "anthropic";
              apiKey = "''${ANTHROPIC_API_KEY}";
            }
          ];
          defaultModel = "claude-sonnet-4-6";
        }
      '';
      description = ''
        JSON configuration written to {file}`~/.t3/userdata/settings.json`.
        Merged with any structured options below.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [cfg.package];

    home.file.".t3/userdata/settings.json" = lib.mkIf (cfg.settings != {}) {
      source = jsonFormat.generate "t3-code-settings.json" cfg.settings;
    };
  };
}
