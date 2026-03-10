{lib}: let
  ## Directory paths
  commandsDir = ./commands;
  skillsDir = ./skills;
  agentsDir = ./agents;
  rulesDir = ./rules;

  ## Content readers
  readCommand = name: builtins.readFile "${commandsDir}/${name}.md";
  readSkill = name: builtins.readFile "${skillsDir}/${name}.md";
  readAgent = name: builtins.readFile "${agentsDir}/${name}.md";
  readRule = name: builtins.readFile "${rulesDir}/${name}.md";

  ## Memory/rule loading instruction (shared across tools)
  memoryInstruction = ''
    ## External File Loading

    CRITICAL: When you encounter a file reference (e.g., @rules/general.md), use your Read tool to load it on a need-to-know basis. They're relevant to the SPECIFIC task at hand.

    Instructions:

    - Do NOT preemptively load all references - use lazy loading based on actual need
    - When loaded, treat content as mandatory instructions that override defaults
    - Follow references recursively when needed
  '';

  ## YAML frontmatter generator
  mkYamlFrontmatter = attrs: let
    formatValue = v:
      if builtins.isList v
      then "[${lib.concatMapStringsSep ", " (x: "\"${x}\"") v}]"
      else if builtins.isAttrs v
      then "\n${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: val: "  ${k}: ${val}") v)}"
      else v;
    lines = lib.mapAttrsToList (k: v: "${k}: ${formatValue v}") attrs;
  in "---\n${lib.concatStringsSep "\n" lines}\n---\n";
in {
  inherit
    readCommand
    readSkill
    readAgent
    readRule
    memoryInstruction
    mkYamlFrontmatter
    ;
}
