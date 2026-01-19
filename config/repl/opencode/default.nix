{
  pkgs,
  lib,
  config,
  ai-nixCfg,
  ...
}: let
  inherit (lib) mkIf;
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  imports = lib.custom.scanPaths ./.;

  home.packages = mkIf config.programs.opencode.enable (lib.attrsets.attrValues {
    inherit (customPkgs) ccusage-opencode;
  });

  programs.opencode = let
    package = pkgs.writeShellScriptBin "opencode" ''
      exec ${pkgs.pnpm}/bin/pnpm dlx opencode-ai "$@"
    '';
    # package = customPkgs.opencode;
  in {
    enable = true;
    inherit package;

    enableMcpIntegration = false;

    settings = {
      autoupdate = false;
      autoshare = false;

      plugin = [
        "oh-my-opencode"
        "opencode-antigravity-auth@beta"
      ];
    };
  };
}
