{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.codex.skills = common.codex.skills;
}
