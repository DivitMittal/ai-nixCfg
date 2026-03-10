{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.gemini-cli = {
    inherit (common.gemini) commands;
    settings.context.fileName = ["AGENTS.md"];
    context.AGENTS = common.gemini.rules;
  };
}
