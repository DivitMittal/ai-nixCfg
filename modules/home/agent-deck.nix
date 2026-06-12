{
  config,
  lib,
  pkgs,
  llm-agents,
  ...
}: let
  cfg = config.programs.agent-deck;
in {
  options.programs.agent-deck = {
    enable = lib.mkEnableOption "agent-deck";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.agent-deck];
  };
}
