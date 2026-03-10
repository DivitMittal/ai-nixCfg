{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.github-copilot = {
    inherit (common.copilot) commands;
  };
}
