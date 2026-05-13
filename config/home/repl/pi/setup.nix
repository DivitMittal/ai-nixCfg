{
  pkgs,
  ai-nixCfg,
  ...
}: let
  coding-agents-overlay = ai-nixCfg.inputs.coding-agents.overlays.default;
  coding-agents-pkgs = coding-agents-overlay pkgs pkgs;
in {
  home.packages = [
    coding-agents-pkgs.pi-coding-agent
  ];
}
