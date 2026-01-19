{lib, ...}: let
  common = import ../common {inherit lib;};
in {
  programs.gemini-cli.settings.context.fileName = ["AGENTS.md"];

  programs.gemini-cli.context = {
    AGENTS = common.gemini.rules;
  };
}
