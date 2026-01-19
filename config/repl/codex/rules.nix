{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.codex.custom-instructions = common.codex.rules;
}
