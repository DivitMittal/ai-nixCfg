{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
in {
  imports = lib.custom.scanPaths ./.;

  home.packages = mkIf config.programs.claude-code.enable (lib.attrsets.attrValues {
    ## CCUsage
    inherit (pkgs) ccusage;
    ## CCStatusLine
    inherit (pkgs) ccstatusline;
    claude-code-switcher = pkgs.writeShellScriptBin "ccs" ''
      exec ${pkgs.pnpm}/bin/pnpm dlx @kaitranntt/ccs "$@"
    '';
  });

  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
  };
}
