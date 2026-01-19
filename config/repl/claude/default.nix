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

  home.packages = mkIf config.programs.claude-code.enable (lib.attrsets.attrValues {
    inherit (customPkgs) ccusage;
    claude-code-switcher = pkgs.writeShellScriptBin "ccs" ''
      exec ${pkgs.pnpm}/bin/pnpm dlx @kaitranntt/ccs "$@"
    '';
  });

  programs.claude-code = {
    enable = true;
    package = customPkgs.claude-code;
  };
}
