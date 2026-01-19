{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.claude-code.commands = common.claude.commands;
}
