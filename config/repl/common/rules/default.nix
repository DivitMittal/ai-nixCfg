{lib}: let
  inherit (import ../lib.nix {inherit lib;}) readRule memoryInstruction;

  ## Rule names (derived from directory contents)
  ruleNames = ["git-workflow" "security" "documentation" "code-quality"];

  ## Combined rules for tools that need all rules in one string
  combinedRules = lib.concatStringsSep "\n\n---\n\n" (map readRule ruleNames);
in {
  inherit ruleNames;

  ## Pre-generated rule sets
  # Claude: individual rules as attrset
  claude.rules = lib.genAttrs ruleNames readRule;

  # Other tools: combined rules with separator
  codex.rules = memoryInstruction + "\n\n" + combinedRules;
  opencode.rules = memoryInstruction + "\n\n" + combinedRules;
  gemini.rules = memoryInstruction + "\n\n" + combinedRules;
  crush.rules = memoryInstruction + "\n\n" + combinedRules;
  copilot.rules = memoryInstruction + "\n\n" + combinedRules;
}
