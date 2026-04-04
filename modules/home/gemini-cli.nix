{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption;
  cfg = config.programs.gemini-cli;
  jsonFormat = pkgs.formats.json {};

  transformMcpServer = name: server:
    lib.nameValuePair name (
      if server ? url
      then
        {httpUrl = server.url;}
        // lib.optionalAttrs (server ? headers) {inherit (server) headers;}
      else if server ? command
      then
        {inherit (server) command;}
        // lib.optionalAttrs (server ? args) {inherit (server) args;}
        // lib.optionalAttrs (server ? env) {inherit (server) env;}
      else {}
    );

  transformedMcpServers =
    if cfg.enableMcpIntegration && config.programs.mcp.enable && config.programs.mcp.servers != {}
    then lib.listToAttrs (lib.mapAttrsToList transformMcpServer config.programs.mcp.servers)
    else {};

  mergedMcpServers = transformedMcpServers // (cfg.settings.mcpServers or {});

  mergedSettings =
    cfg.settings
    // lib.optionalAttrs (mergedMcpServers != {}) {mcpServers = mergedMcpServers;};
in {
  options.programs.gemini-cli = {
    enableMcpIntegration = mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to integrate the MCP servers config from
        {option}`programs.mcp.servers` into
        {option}`programs.gemini-cli.settings.mcpServers`.

        Note: Settings defined in {option}`programs.gemini-cli.settings.mcpServers`
        take precedence over those from {option}`programs.mcp.servers`.
      '';
    };

    skills = mkOption {
      type =
        lib.types.either (lib.types.attrsOf (
          lib.types.oneOf [
            lib.types.lines
            lib.types.path
            lib.types.str
          ]
        ))
        lib.types.path;
      default = {};
      description = ''
        Custom agent skills for gemini-cli.

        This option can either be:
        - An attribute set defining skills
        - A path to a directory containing skill folders

        If an attribute set is used, the attribute name becomes the skill directory name,
        and the value is either:
        - Inline content as a string (creates `.gemini/skills/<name>/SKILL.md`)
        - A path to a file (creates `.gemini/skills/<name>/SKILL.md`)
        - A path to a directory (creates `.gemini/skills/<name>/` with all files)

        If a path is used, it is expected to contain one folder per skill name, each
        containing a `SKILL.md`. The directory is symlinked to
        {file}`~/.gemini/skills/`.
      '';
      example = lib.literalExpression ''
        {
          nix-flakes = '''
            ---
            name: nix-flakes
            description: Deep knowledge of Nix flakes. Use when working with flake.nix, inputs, or outputs.
            ---

            # Nix Flakes Expertise
          ''';

          data-analysis = ./skills/data-analysis;
        }
      '';
    };
  };

  config = mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = !lib.isPath cfg.skills || lib.pathIsDirectory cfg.skills;
          message = "'programs.gemini-cli.skills' must be a directory when set to a path";
        }
      ];
    }

    # MCP integration: override settings.json to merge global MCP servers
    (mkIf (cfg.enableMcpIntegration && transformedMcpServers != {}) {
      home.file.".gemini/settings.json" = lib.mkForce {
        source = jsonFormat.generate "gemini-cli-settings.json" mergedSettings;
      };
    })

    # Skills: symlink entire directory
    (mkIf (lib.isPath cfg.skills) {
      home.file.".gemini/skills" = {
        source = cfg.skills;
        recursive = true;
      };
    })

    # Skills: individual skill files from attrset
    (lib.mkIf (builtins.isAttrs cfg.skills && cfg.skills != {}) {
      home.file =
        lib.mapAttrs' (
          name: content:
            if
              (lib.isPath content && lib.pathIsDirectory content)
              || (builtins.isString content && lib.hasPrefix builtins.storeDir content)
            then
              lib.nameValuePair ".gemini/skills/${name}" {
                source = content;
                recursive = true;
              }
            else
              lib.nameValuePair ".gemini/skills/${name}/SKILL.md" (
                if lib.isPath content
                then {source = content;}
                else {text = content;}
              )
        )
        cfg.skills;
    })
  ]);
}
