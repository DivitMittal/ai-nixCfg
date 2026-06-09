{lib, ...}: let
  common = import ../_common {inherit lib;};
  inherit (common.lib) memoryInstruction;
  inherit (common.rules) combinedRules;
in {
  programs.opencode = {
    context = memoryInstruction + "\n\n" + combinedRules;
  };
}
