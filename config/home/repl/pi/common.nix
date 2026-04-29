{lib, ...}: let
  common = import ../_common {inherit lib;};
  inherit (common.lib) memoryInstruction;
  inherit (common.commands) commandMeta commandNames readCommand;
  inherit (common.skills) skillMeta skillNames readSkill;
  inherit (common.agents) agentMeta agentNames readAgent;
  inherit (common.rules) combinedRules;

  ## Pi prompts: markdown files in ~/.pi/agent/prompts/
  mkPromptFile = name: let
    meta = commandMeta.${name};
    body = readCommand name;
    header = "# ${meta.description}\n\n";
  in {
    "prompts/${name}.md" = {
      text = header + body;
    };
  };

  promptFiles = lib.foldl' (acc: name: acc // (mkPromptFile name)) {} commandNames;

  ## Pi skills: markdown files in ~/.pi/agent/skills/
  mkSkillFile = name: let
    meta = skillMeta.${name};
    body = readSkill name;
    header = "# ${meta.name}\n\n${meta.description}\n\n";
  in {
    "skills/${name}.md" = {
      text = header + body;
    };
  };

  skillFiles = lib.foldl' (acc: name: acc // (mkSkillFile name)) {} skillNames;

  ## Pi skills from agent definitions (pi lacks native subagents, expose as skills)
  mkAgentSkillFile = name: let
    meta = agentMeta.${name};
    body = readAgent name;
    header = "# Agent: ${meta.name}\n\n${meta.description}\n\n";
  in {
    "skills/agent-${name}.md" = {
      text = header + body;
    };
  };

  agentSkillFiles = lib.foldl' (acc: name: acc // (mkAgentSkillFile name)) {} agentNames;

  ## AGENTS.md: global context with rules
  agentsFile = {
    "AGENTS.md" = {
      text = memoryInstruction + "\n\n" + combinedRules;
    };
  };

  allFiles = promptFiles // skillFiles // agentSkillFiles // agentsFile;
in {
  home.file = lib.mapAttrs' (name: value:
    lib.nameValuePair ".pi/agent/${name}" value)
  allFiles;
}
