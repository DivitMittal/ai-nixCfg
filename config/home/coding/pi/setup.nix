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
  piExtensions = ai-nixCfg.inputs.coding-agents + "/home-manager/pi-coding-agent/extensions";
in {
  programs.pi.coding-agent = lib.mkIf isSupported {
    enable = true;
    extensions = [piExtensions];
  };

  home.packages = lib.optionals isSupported (
    [
      pkgs.nil
      pkgs.basedpyright
      pkgs.typescript-language-server
      pkgs.typescript
      pkgs.gopls
      pkgs.go
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.wl-clipboard
    ]
  );
}
