{
  pkgs,
  ai-nixCfg,
  lib,
  ...
}: let
  inherit (pkgs.stdenvNoCC.hostPlatform) system;
in {
  programs.hermes-agent = {
    enable = true;
    package = lib.mkDefault (ai-nixCfg.inputs.llm-agents.packages.${system}.hermes-agent or null);
  };
}
