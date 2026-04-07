{lib, ...}: let
  common = import ../common {inherit lib;};
  inherit (common.lib) memoryInstruction;
  inherit (common.rules) combinedRules;
in {
  programs.opencode = {
    rules = memoryInstruction + "\n\n" + combinedRules;
  };
}
