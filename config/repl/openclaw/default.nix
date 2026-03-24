{
  pkgs,
  ai-nixCfg,
  lib,
  ...
}: let
  system = pkgs.stdenvNoCC.hostPlatform.system;
  isAarch64Darwin = pkgs.stdenvNoCC.hostPlatform.isAarch64 && pkgs.stdenvNoCC.hostPlatform.isDarwin;
in {
  # nix-openclaw and all steipete plugins only support aarch64-darwin
  home.packages = lib.mkIf isAarch64Darwin [
    ai-nixCfg.packages.${system}.openclaw
  ];

  programs.openclaw = lib.mkIf isAarch64Darwin {
    enable = true;
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
      bird.enable = true;
      imsg.enable = true;
    };
  };
}
