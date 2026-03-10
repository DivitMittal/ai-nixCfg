{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.codex = {
    inherit (common.codex) prompts skills;
    custom-instructions = common.codex.rules;
  };
}
