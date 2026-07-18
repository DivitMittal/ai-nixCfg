{
  config,
  lib,
  ...
}: let
  common = import ../../coding/_common {inherit lib;};
  inherit (common.lib) memoryInstruction;
  inherit (common.rules) combinedRules;

  sharedInstructions = memoryInstruction + "\n\n" + combinedRules;
in {
  programs.hermes-agent = lib.mkIf config.programs.hermes-agent.enable {
    documents = {
      "SOUL.md" = ''
        # Hermes Agent

        You are Hermes Agent, a local coding and research assistant configured declaratively through Home Manager.

        Prefer concise, practical answers. Use available tools deliberately. Avoid exposing secrets or embedding private identity assumptions in generated output.
      '';

      "USER.md" = sharedInstructions;
    };
  };
}
