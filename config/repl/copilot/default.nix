{
  pkgs,
  lib,
  self,
  ...
}: let
  myPkgs = self.packages.${pkgs.system};
in {
  imports =
    (lib.custom.scanPaths ./.)
    ++ [
      self.homeManagerModules.github-copilot
    ];

  programs.github-copilot = let
    package = pkgs.writeShellScriptBin "copilot" ''
      exec ${myPkgs.copilot-cli}/bin/copilot --enable-all-github-mcp-tools --banner "$@"
    '';
  in {
    enable = true;
    inherit package;
  };
}
