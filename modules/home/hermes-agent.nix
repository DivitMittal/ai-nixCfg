{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.programs.hermes-agent;

  yamlFormat = pkgs.formats.yaml {};

  mcpServerType = types.submodule {
    options = {
      command = mkOption {
        type = types.str;
        description = "The MCP server command to execute.";
      };
      args = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Arguments to pass to the MCP server command.";
      };
      env = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Environment variables for the MCP server process.";
      };
      disabled = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this MCP server is disabled.";
      };
    };
  };

  # hermes config.yaml expects mcp.servers as a list with a `name` field
  mcpServersToList = servers:
    lib.mapAttrsToList (name: server: {inherit name;} // server) servers;

  mergedSettings = lib.recursiveUpdate cfg.settings (
    lib.optionalAttrs (cfg.mcp != {}) {
      mcp.servers = mcpServersToList cfg.mcp;
    }
  );
in {
  options.programs.hermes-agent = {
    enable = lib.mkEnableOption "Hermes Agent — self-improving AI agent by Nous Research";

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = ''
        The hermes-agent package to install.
        Set to null (the default) to skip package installation while still managing config.
        The package is available via the llm-agents flake input.
      '';
    };

    settings = mkOption {
      inherit (yamlFormat) type;
      default = {};
      example = lib.literalExpression ''
        {
          model = {
            provider = "anthropic";
            model = "claude-sonnet-4-6";
          };
          memory = {
            max_chars = 10000;
          };
          session = {
            auto_reset = "idle";
          };
        }
      '';
      description = ''
        YAML configuration written to {file}`~/.hermes/config.yaml`.
        Merged with the structured options below (mcp takes precedence when both define servers).
        See https://hermes-agent.nousresearch.com/docs/user-guide/configuration for all options.
      '';
    };

    mcp = mkOption {
      type = types.attrsOf mcpServerType;
      default = {};
      example = lib.literalExpression ''
        {
          filesystem = {
            command = "npx";
            args = ["-y" "@modelcontextprotocol/server-filesystem" "~"];
          };
          memory = {
            command = "npx";
            args = ["-y" "@modelcontextprotocol/server-memory"];
          };
        }
      '';
      description = ''
        Model Context Protocol (MCP) server configurations.
        Each attribute name becomes the {literal}`name` field of the server entry
        in {literal}`mcp.servers` within config.yaml.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [cfg.package];

    home.file.".hermes/config.yaml" = lib.mkIf (mergedSettings != {}) {
      source = yamlFormat.generate "hermes-config.yaml" mergedSettings;
    };
  };
}
