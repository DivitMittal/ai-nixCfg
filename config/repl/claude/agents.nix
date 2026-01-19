{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.claude-code.agents = common.claude.agents;
}
