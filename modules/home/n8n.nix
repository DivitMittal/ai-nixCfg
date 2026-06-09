{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.programs.n8n;

  environmentValueType = types.oneOf [types.str types.int types.bool];

  formatEnvironmentValue = value:
    if lib.isBool value
    then lib.boolToString value
    else toString value;

  environment =
    {
      N8N_USER_FOLDER = cfg.userFolder;
    }
    // cfg.environment;
in {
  options.programs.n8n = {
    enable = lib.mkEnableOption "n8n workflow automation platform";

    package = lib.mkPackageOption pkgs "n8n" {nullable = true;};

    userFolder = mkOption {
      type = types.str;
      default = "${config.xdg.stateHome}/n8n";
      defaultText = lib.literalExpression ''"\${config.xdg.stateHome}/n8n"'';
      description = ''
        Parent directory for n8n state, exposed as {env}`N8N_USER_FOLDER`.

        n8n creates and manages a {file}`.n8n` directory below this path for
        runtime state such as the SQLite database and generated encryption-key
        settings. Keep this directory persistent.
      '';
    };

    environment = mkOption {
      type = types.attrsOf environmentValueType;
      default = {};
      example = lib.literalExpression ''
        {
          N8N_PORT = 5678;
          N8N_LISTEN_ADDRESS = "127.0.0.1";
          DB_TYPE = "sqlite";
          DB_SQLITE_DATABASE = "\${config.xdg.stateHome}/n8n/.n8n/database.sqlite";
          N8N_DIAGNOSTICS_ENABLED = false;
          N8N_VERSION_NOTIFICATIONS_ENABLED = false;
        }
      '';
      description = ''
        Environment variables for n8n.

        n8n is primarily configured through environment variables. Do not place
        secret values directly in this option because they may be written to the
        Nix store through generated activation or service files. Prefer n8n's
        {env}`*_FILE` variables pointing at runtime-managed secret files.
      '';
    };

    environmentFiles = mkOption {
      type = types.listOf types.str;
      default = [];
      example = lib.literalExpression ''
        ["%h/.config/n8n/secrets.env"]
      '';
      description = ''
        Runtime environment files for the n8n user service.

        Use this for secrets or host-specific values. The files are referenced by
        the systemd user unit and should not be Nix store paths when they contain
        secrets.
      '';
    };

    service = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to run n8n as a systemd user service.

          This is only supported on Linux Home Manager hosts with systemd user
          services. Darwin users can still enable the package and run n8n
          manually with the declarative environment documented by this module.
        '';
      };

      wantedBy = mkOption {
        type = types.listOf types.str;
        default = ["default.target"];
        description = "Systemd user targets that should start the n8n service.";
      };

      extraServiceConfig = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        example = lib.literalExpression ''
          {
            RestartSec = 10;
          }
        '';
        description = "Additional systemd service settings for n8n.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.package != null || !cfg.service.enable;
        message = "programs.n8n.service.enable requires programs.n8n.package to be non-null.";
      }
      {
        assertion = pkgs.stdenv.isLinux || !cfg.service.enable;
        message = "programs.n8n.service.enable is only supported on Linux systemd user sessions.";
      }
    ];

    home.packages = mkIf (cfg.package != null) [cfg.package];

    home.sessionVariables = lib.mapAttrs (_: formatEnvironmentValue) environment;

    home.activation.n8nStateDirectory = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg cfg.userFolder}
    '';

    systemd.user.services.n8n = mkIf cfg.service.enable {
      Unit = {
        Description = "n8n workflow automation platform";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };

      Service =
        {
          ExecStart = "${lib.getExe cfg.package} start";
          Environment =
            lib.mapAttrsToList (
              name: value: "${name}=${formatEnvironmentValue value}"
            )
            environment;
          EnvironmentFile = cfg.environmentFiles;
          Restart = "on-failure";
          WorkingDirectory = cfg.userFolder;
        }
        // cfg.service.extraServiceConfig;

      Install.WantedBy = cfg.service.wantedBy;
    };
  };
}
