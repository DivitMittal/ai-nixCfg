{lib, ...}: let
  common = import ../_common {inherit lib;};
  inherit (common.lib) mkYamlFrontmatter memoryInstruction;
  inherit (common.commands) commandMeta commandNames readCommand;
  inherit (common.agents) agentMeta agentNames readAgent;
  inherit (common.rules) combinedRules;

  ## Upstream Copilot CLI dropped `commands` in favour of `skills`
  ## (each rendered to skills/<name>/SKILL.md). Slash commands become skills,
  ## whose frontmatter expects `name` + `description`.
  mkSkill = name: let
    meta = commandMeta.${name};
    body = readCommand name;
    frontmatter = {
      inherit name;
      inherit (meta) description;
    };
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
    skills = lib.genAttrs commandNames mkSkill;
    agents = lib.genAttrs agentNames mkAgent;
    context = memoryInstruction + "\n\n" + combinedRules;
  };
}
