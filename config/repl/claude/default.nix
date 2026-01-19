{
  pkgs,
  lib,
  config,
  self,
  ...
}: let
  inherit (lib) mkIf;
  customPkgs = self.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  imports =
    (lib.custom.scanPaths ./.)
    ++ [
      self.homeManagerModules.claude-code
    ];

  home.packages = mkIf config.programs.claude-code.enable (lib.attrsets.attrValues {
    inherit (customPkgs) ccusage ccstatusline;
    claude-code-switcher = pkgs.writeShellScriptBin "ccs" ''
      exec ${pkgs.pnpm}/bin/pnpm dlx @kaitranntt/ccs "$@"
    '';
  });

  programs.claude-code = {
    enable = true;
    package = customPkgs.claude-code;
  };
}
