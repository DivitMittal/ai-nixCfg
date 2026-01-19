{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.gemini-cli.commands = common.gemini.commands;
}
