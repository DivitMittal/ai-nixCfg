{
  config,
  lib,
  pkgs,
  llm-agents,
  ...
}: let
  cfg = config.programs.agent-deck;
  fmt = pkgs.formats.toml {};
in {
  options.programs.agent-deck = {
    enable = lib.mkEnableOption "agent-deck";

    settings = lib.mkOption {
      inherit (fmt) type;
      default = {};
      description = ''
        agent-deck config written to
        {file}`$XDG_CONFIG_HOME/agent-deck/config.toml`
        (agent-deck resolves `XDG_CONFIG_HOME` with a `~/.config` fallback).

        Schema reference:
        https://github.com/asheshgoplani/agent-deck/blob/main/skills/agent-deck/references/config-reference.md
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.agent-deck];
    xdg.configFile."agent-deck/config.toml".source = fmt.generate "config.toml" cfg.settings;
  };
}
