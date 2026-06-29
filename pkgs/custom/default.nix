{pkgs}: let
  sources = pkgs.callPackage ../_sources/generated.nix {};
in {
  gowa = pkgs.callPackage ./gowa/package.nix {inherit sources;};
  lightpanda = pkgs.callPackage ./lightpanda/package.nix {inherit sources;};
}
