{
  pkgs,
  ai-nixCfg,
  lib,
  ...
}: let
  inherit (pkgs.stdenvNoCC.hostPlatform) system;
  isAarch64Darwin = pkgs.stdenvNoCC.hostPlatform.isAarch64 && pkgs.stdenvNoCC.hostPlatform.isDarwin;
in {
  home.packages =
    [
      ai-nixCfg.packages.${system}.summarize
      ai-nixCfg.packages.${system}.gogcli
    ]
    # nix-openclaw and all steipete plugins only support aarch64-darwin
    ++ lib.optionals isAarch64Darwin [
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
      imsg.enable = true;
    };
  };
}
