{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.claude-code = {
    inherit (common.claude) commands skills agents rules;
    memory.text = common.memory;
  };
}
