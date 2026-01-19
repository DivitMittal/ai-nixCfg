{pkgs}: {
  bv-bin = pkgs.callPackage ./bv-bin/package.nix {};
  gowa = pkgs.callPackage ./gowa/package.nix {};
}
