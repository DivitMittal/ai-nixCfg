{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.opencode = {
    inherit (common.opencode) rules;
  };
}
