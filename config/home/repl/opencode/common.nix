{lib, ...}: let
  common = import ../_common {inherit lib;};
  inherit (common.lib) memoryInstruction;
  inherit (common.rules) combinedRules;
in {
  programs.opencode = {
    rules = memoryInstruction + "\n\n" + combinedRules;
  };
}
