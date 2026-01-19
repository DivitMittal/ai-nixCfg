{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.codex.prompts = common.codex.prompts;
}
