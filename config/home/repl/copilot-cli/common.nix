{lib, ...}: let
  common = import ../_common {inherit lib;};
  inherit (common.lib) mkYamlFrontmatter memoryInstruction;
  inherit (common.commands) commandMeta commandNames readCommand;
  inherit (common.agents) agentMeta agentNames readAgent;
  inherit (common.rules) combinedRules;

  mkCommand = name: let
    meta = commandMeta.${name};
    body = readCommand name;
    frontmatter =
      {inherit (meta) description;}
      // lib.optionalAttrs (meta ? argument-hint) {inherit (meta) argument-hint;}
      // lib.optionalAttrs (meta ? tools) {inherit (meta) tools;};
  in
    mkYamlFrontmatter frontmatter + body;

  mkAgent = name: let
    meta = agentMeta.${name};
    body = readAgent name;
    frontmatter = {
      inherit (meta) description;
      tools = meta.copilot-tools;
    };
  in
    mkYamlFrontmatter frontmatter + body;
in {
  programs.github-copilot-cli = {
    commands = lib.genAttrs commandNames mkCommand;
    agents = lib.genAttrs agentNames mkAgent;
    context = memoryInstruction + "\n\n" + combinedRules;
  };
}
