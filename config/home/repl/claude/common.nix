{lib, ...}: let
  common = import ../_common {inherit lib;};
  inherit (common.lib) mkYamlFrontmatter memoryInstruction;
  inherit (common.commands) commandMeta commandNames readCommand;
  inherit (common.skills) skillMeta skillNames readSkill;
  inherit (common.agents) agentMeta agentNames readAgent;
  inherit (common.rules) ruleNames readRule;

  mkCommand = name: let
    meta = commandMeta.${name};
    body = readCommand name;
    frontmatter =
      {inherit (meta) description;}
      // lib.optionalAttrs (meta ? allowed-tools) {inherit (meta) allowed-tools;}
      // lib.optionalAttrs (meta ? argument-hint) {inherit (meta) argument-hint;};
  in
    mkYamlFrontmatter frontmatter + body;

  mkSkill = name: let
    meta = skillMeta.${name};
    body = readSkill name;
    frontmatter = {inherit (meta) name description;};
  in
    mkYamlFrontmatter frontmatter + body;

  mkAgent = name: let
    meta = agentMeta.${name};
    body = readAgent name;
    frontmatter = {
      inherit (meta) name description model;
      inherit (meta) tools;
    };
  in
    mkYamlFrontmatter frontmatter + body;
in {
  programs.claude-code = {
    commands = lib.genAttrs commandNames mkCommand;
    skills = lib.genAttrs skillNames mkSkill;
    agents = lib.genAttrs agentNames mkAgent;
    rules = lib.genAttrs ruleNames readRule;
    memory.text = memoryInstruction;
  };
}
