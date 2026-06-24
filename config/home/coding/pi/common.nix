{
  lib,
  pkgs,
  ...
}: let
  common = import ../_common {inherit lib;};
  inherit (common.lib) memoryInstruction;
  inherit (common.commands) commandMeta commandNames readCommand;
  inherit (common.skills) skillMeta skillNames readSkill;
  inherit (common.agents) agentMeta agentNames readAgent;
  inherit (common.rules) combinedRules;

  mkSkillEntry = name: let
    meta = skillMeta.${name};
  in {
    name = "${name}.md";
    path = pkgs.writeText "${name}.md" ("# ${meta.name}\n\n${meta.description}\n\n" + readSkill name);
  };

  mkAgentSkillEntry = name: let
    meta = agentMeta.${name};
  in {
    name = "agent-${name}.md";
    path = pkgs.writeText "agent-${name}.md" ("# Agent: ${meta.name}\n\n${meta.description}\n\n" + readAgent name);
  };

  skillsDir =
    pkgs.linkFarm "pi-skills"
    (map mkSkillEntry skillNames ++ map mkAgentSkillEntry agentNames);

  mkPromptEntry = name: let
    meta = commandMeta.${name};
  in {
    name = "${name}.md";
    path = pkgs.writeText "${name}.md" ("# ${meta.description}\n\n" + readCommand name);
  };

  promptsDir = pkgs.linkFarm "pi-prompts" (map mkPromptEntry commandNames);
in {
  programs.pi.coding-agent = {
    rules = memoryInstruction + "\n\n" + combinedRules;
    skills = [skillsDir];
    promptTemplates = [promptsDir];
  };
}
