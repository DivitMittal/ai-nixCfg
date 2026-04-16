{
  pkgs,
  lib,
  ai-nixCfg,
  ...
}: let
  isSupported =
    pkgs.stdenvNoCC.hostPlatform.isAarch64
    && pkgs.stdenvNoCC.hostPlatform.isDarwin
    || pkgs.stdenvNoCC.hostPlatform.isLinux;
  coding-agents-overlay = ai-nixCfg.inputs.coding-agents.overlays.default;
  coding-agents-pkgs = coding-agents-overlay pkgs pkgs;
in {
  home.packages = lib.mkIf isSupported [
    coding-agents-pkgs.pi-coding-agent
  ];
}
