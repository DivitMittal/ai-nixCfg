{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types literalExpression;
  cfg = config.programs.codex;
in {
  options.programs.codex = {
    prompts = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = literalExpression ''
        {
          explain = '''
            ---
            description: Explain code in detail
            argument-hint: <file-or-symbol>
            ---

            Provide a detailed explanation of the specified code.
          ''';
        }
      '';
      description = ''
        Custom prompts for Codex CLI.

        Each attribute defines a custom prompt. The attribute name becomes the prompt filename,
        and the value is the prompt content with optional YAML frontmatter.
        Prompts are stored in {file}`$XDG_CONFIG_HOME/codex/prompts/<name>.md`.
      '';
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile = lib.mkMerge [
      # Prompts: each prompt is a markdown file (Slash Commands)
      (lib.mapAttrs' (name: content:
        lib.nameValuePair "codex/prompts/${name}.md" {
          text = content;
        })
      cfg.prompts)
    ];
  };
}
