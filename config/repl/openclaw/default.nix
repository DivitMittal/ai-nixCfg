{
  pkgs,
  ai-nixCfg,
  ...
}: let
  system = pkgs.stdenvNoCC.hostPlatform.system;
  customPkgs = ai-nixCfg.packages.${system};
  gatewayPkg = ai-nixCfg.inputs.nix-openclaw.packages.${system}.openclaw-gateway;
  isAarch64Darwin = pkgs.stdenvNoCC.hostPlatform.isAarch64 && pkgs.stdenvNoCC.hostPlatform.isDarwin;
in {
  home.packages = [ customPkgs.openclaw ];

  programs.openclaw = {
    enable = true;
    package = gatewayPkg;

    # nix-steipete-tools only provides packages for aarch64-darwin; disable on x86_64-darwin
    bundledPlugins = {
      summarize.enable = isAarch64Darwin;
      camsnap.enable = isAarch64Darwin;
      gogcli.enable = isAarch64Darwin;
      goplaces.enable = isAarch64Darwin;
      sag.enable = isAarch64Darwin;
      sonoscli.enable = isAarch64Darwin;
      peekaboo.enable = isAarch64Darwin;
      poltergeist.enable = isAarch64Darwin;
      bird.enable = isAarch64Darwin;
      imsg.enable = isAarch64Darwin;
    };
  };
}
