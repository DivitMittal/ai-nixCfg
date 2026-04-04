{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption;
  cfg = config.programs.github-copilot-cli;
in {
  options.programs.github-copilot-cli = {
    commands = mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = lib.literalExpression ''
        {
          commit = '''
            ---
            description: Create a git commit with proper message
            tools: ["terminal"]
            ---
            Create an atomic git commit with a descriptive conventional commit message.
          ''';
        }
      '';
      description = ''
        Custom slash commands for GitHub Copilot CLI.

        Each attribute defines a command. The attribute name becomes the command filename,
        and the value is the command content with optional YAML frontmatter.
        Commands are written to {file}`''${configDir}/commands/<name>.md`.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.file = lib.mapAttrs' (name: content:
      lib.nameValuePair "${cfg.configDir}/commands/${name}.md" {
        text = content;
      })
    cfg.commands;
  };
}
