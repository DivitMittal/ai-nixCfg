{
  pkgs,
  ai-nixCfg,
  lib,
  ...
}: let
  inherit (pkgs.stdenvNoCC.hostPlatform) system;
  isAarch64Darwin = pkgs.stdenvNoCC.hostPlatform.isAarch64 && pkgs.stdenvNoCC.hostPlatform.isDarwin;
in {
  # nix-openclaw and all steipete plugins only support aarch64-darwin
  home.packages = lib.optionals false [
    # Archived; was isAarch64Darwin.
    ai-nixCfg.packages.${system}.summarize
    ai-nixCfg.packages.${system}.gogcli
    ai-nixCfg.packages.${system}.openclaw
  ];

  programs.openclaw = lib.mkIf isAarch64Darwin {
    enable = false; # Archived: not in active use.
    package = ai-nixCfg.inputs.nix-openclaw.packages.${system}.openclaw-gateway;

    bundledPlugins = {
      summarize.enable = true;
      camsnap.enable = true;
      gogcli.enable = true;
      goplaces.enable = true;
      sag.enable = true;
      sonoscli.enable = true;
      peekaboo.enable = true;
      poltergeist.enable = true;
      imsg.enable = true;
    };
  };
}
