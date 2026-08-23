{pkgs}: let
  sources = pkgs.callPackage ../_sources/generated.nix {};
in {
  cliproxyapi-plus = pkgs.callPackage ./cliproxyapi-plus/package.nix {inherit sources;};
  gowa = pkgs.callPackage ./gowa/package.nix {inherit sources;};
  jcode = pkgs.callPackage ./jcode/package.nix {inherit sources;};
  lightpanda = pkgs.callPackage ./lightpanda/package.nix {inherit sources;};
  lumen = pkgs.callPackage ./lumen/package.nix {inherit sources;};
  pi-agent-rust = pkgs.callPackage ./pi-agent-rust/package.nix {inherit sources;};
  zai = pkgs.callPackage ./zai/package.nix {inherit sources;};
  zerobrew-bin = pkgs.callPackage ./zerobrew-bin/package.nix {inherit sources;};
}
