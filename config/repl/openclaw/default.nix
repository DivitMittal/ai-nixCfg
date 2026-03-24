{
  pkgs,
  ai-nixCfg,
  ...
}: let
  system = pkgs.stdenvNoCC.hostPlatform.system;
  customPkgs = ai-nixCfg.packages.${system};
  gatewayPkg = ai-nixCfg.inputs.nix-openclaw.packages.${system}.openclaw-gateway;
in {
  home.packages = [ customPkgs.openclaw ];

  programs.openclaw = {
    enable = true;
    package = gatewayPkg;

    bundledPlugins = {
      summarize.enable = true;
      camsnap.enable = true;
      gogcli.enable = true;
      goplaces.enable = true;
      sag.enable = true;
      sonoscli.enable = true;
      # macOS-only plugins
      peekaboo.enable = pkgs.stdenvNoCC.hostPlatform.isDarwin;
      poltergeist.enable = pkgs.stdenvNoCC.hostPlatform.isDarwin;
      bird.enable = pkgs.stdenvNoCC.hostPlatform.isDarwin;
      imsg.enable = pkgs.stdenvNoCC.hostPlatform.isDarwin;
    };
  };
}
