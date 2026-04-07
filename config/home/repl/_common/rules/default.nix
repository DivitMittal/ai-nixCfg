{lib}: let
  inherit (import ../lib.nix {inherit lib;}) readRule;

  ## Rule names (derived from directory contents)
  ruleNames = ["git-workflow" "security" "documentation" "code-quality"];

  ## Combined rules for tools that need all rules in one string
  combinedRules = lib.concatStringsSep "\n\n---\n\n" (map readRule ruleNames);
in {
  inherit ruleNames readRule combinedRules;
}
