{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.github-copilot.agents = common.copilot.agents;
}
