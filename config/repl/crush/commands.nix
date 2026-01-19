{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.crush.commands = common.crush.commands;
}
