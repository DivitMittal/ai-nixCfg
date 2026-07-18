{
  pkgs,
  ai-nixCfg,
  lib,
  ...
}: let
  inherit (pkgs.stdenvNoCC.hostPlatform) system;
  llmPkgs = ai-nixCfg.inputs.llm-agents.packages.${system} or {};
  fallbackPkgs = ai-nixCfg.inputs.nix-hermes-agent.packages.${system} or {};

  hermesPackage =
    llmPkgs.hermes-agent or fallbackPkgs.hermes-agent or null;
in {
  programs.hermes-agent = lib.mkIf (hermesPackage != null) {
    enable = true;
    package = hermesPackage;
  };
}
