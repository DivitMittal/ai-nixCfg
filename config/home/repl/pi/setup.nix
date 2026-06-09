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
  piExtensions = ai-nixCfg.inputs.coding-agents + "/home-manager/pi-coding-agent/extensions";
in {
  home = lib.mkIf isSupported {
    file.".pi/agent/extensions".source = piExtensions;

    packages =
      [
        coding-agents-pkgs.pi-coding-agent
        pkgs.nil
        pkgs.basedpyright
        pkgs.typescript-language-server
        pkgs.typescript
        pkgs.gopls
        pkgs.go
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        pkgs.wl-clipboard
      ];
  };
}
