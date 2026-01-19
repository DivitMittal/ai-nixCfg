{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.crush.settings.instructions = common.crush.rules;
}
