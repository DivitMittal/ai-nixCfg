{lib, ...}: let
  common = import ../_common {inherit lib;};
  inherit (common.lib) memoryInstruction;
  inherit (common.commands) commandMeta commandNames readCommand;
  inherit (common.rules) combinedRules;

  mkCommand = name: let
    meta = commandMeta.${name};
    body = readCommand name;
  in {
    inherit (meta) description;
    prompt = body;
  };
in {
  programs.gemini-cli = {
    commands = lib.genAttrs commandNames mkCommand;
    settings.context.fileName = ["AGENTS.md"];
    context.AGENTS = memoryInstruction + "\n\n" + combinedRules;
  };
}
