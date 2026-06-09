{lib, ...}: let
  common = import ../_common {inherit lib;};
  inherit (common.lib) mkYamlFrontmatter memoryInstruction;
  inherit (common.commands) commandMeta commandNames readCommand;
  inherit (common.skills) skillMeta skillNames readSkill;
  inherit (common.rules) combinedRules;

  mkPrompt = name: let
    meta = commandMeta.${name};
    body = readCommand name;
    frontmatter =
      {inherit (meta) description;}
      // lib.optionalAttrs (meta ? argument-hint) {inherit (meta) argument-hint;};
  in
    mkYamlFrontmatter frontmatter + body;

  mkSkill = name: let
    meta = skillMeta.${name};
    body = readSkill name;
    frontmatter = {inherit (meta) name description;};
  in
    mkYamlFrontmatter frontmatter + body;
in {
  programs.codex = {
    prompts = lib.genAttrs commandNames mkPrompt;
    skills = lib.genAttrs skillNames mkSkill;
    context = memoryInstruction + "\n\n" + combinedRules;
  };
}
