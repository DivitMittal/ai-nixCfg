{lib, ...}: let
  common = import ../_common {inherit lib;};
  inherit (common.lib) memoryInstruction;
  inherit (common.commands) commandMeta commandNames readCommand;
  inherit (common.rules) combinedRules;

  # Commands are migrated to Antigravity CLI global skills.
  mkCommand = name: let
    meta = commandMeta.${name};
    body = readCommand name;
  in {
    inherit (meta) description;
    prompt = body;
  };
in {
  programs.antigravity-cli = {
    commands = lib.genAttrs commandNames mkCommand;
    context.AGENTS = memoryInstruction + "\n\n" + combinedRules;
  };
}
