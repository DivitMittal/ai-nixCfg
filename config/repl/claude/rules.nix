{lib, ...}: let
  common = import ../../common {inherit lib;};
in {
  programs.claude-code = {
    memory.text = common.memory;
    rules = common.claude.rules;
  };
}
