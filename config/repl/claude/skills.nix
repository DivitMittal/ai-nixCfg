{lib, ...}: let
  common = import ../../common {inherit lib;};
in {
  programs.claude-code.skills = common.claude.skills;
}
