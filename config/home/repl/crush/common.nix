{lib, ...}: let
  common = import ../common {inherit lib;};
  inherit (common.lib) mkYamlFrontmatter memoryInstruction;
  inherit (common.commands) commandMeta commandNames readCommand;
  inherit (common.rules) combinedRules;

  ## Same frontmatter format as Claude
  mkCommand = name: let
    meta = commandMeta.${name};
    body = readCommand name;
    frontmatter =
      {inherit (meta) description;}
      // lib.optionalAttrs (meta ? allowed-tools) {inherit (meta) allowed-tools;}
      // lib.optionalAttrs (meta ? argument-hint) {inherit (meta) argument-hint;};
  in
    mkYamlFrontmatter frontmatter + body;
in {
  programs.crush = {
    commands = lib.genAttrs commandNames mkCommand;
    settings.instructions = memoryInstruction + "\n\n" + combinedRules;
  };
}
