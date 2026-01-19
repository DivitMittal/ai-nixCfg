{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.opencode.rules = common.opencode.rules;
}
