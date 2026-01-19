{
  pkgs,
  lib,
  self,
  ...
}: {
  imports =
    (lib.custom.scanPaths ./.)
    ++ [
      self.homeManagerModules.crush
    ];

  programs.crush = {
    enable = false;
    package = pkgs.crush;
  };
}
