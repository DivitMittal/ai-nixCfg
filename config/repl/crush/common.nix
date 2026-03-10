{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.crush = {
    inherit (common.crush) commands;
    settings.instructions = common.crush.rules;
  };
}
