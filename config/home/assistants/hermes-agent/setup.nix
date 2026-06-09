{
  pkgs,
  ai-nixCfg,
  ...
}: let
  inherit (pkgs.stdenvNoCC.hostPlatform) system;
in {
  programs.hermes-agent = {
    enable = true;
    package = ai-nixCfg.inputs.llm-agents.packages.${system}.hermes-agent;
  };
}
