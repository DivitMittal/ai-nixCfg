{
  pkgs,
  ai-nixCfg,
  lib,
  ...
}: let
  inherit (pkgs.stdenvNoCC.hostPlatform) system;
  llmPkgs = ai-nixCfg.inputs.llm-agents.packages.${system} or {};
in {
  programs.hermes-agent = lib.mkIf (llmPkgs ? hermes-agent) {
    enable = true;
    package = llmPkgs.hermes-agent;
  };
}
