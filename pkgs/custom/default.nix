{pkgs}: let
  sources = pkgs.callPackage ../_sources/generated.nix {};
in {
  cliproxyapi-plus = pkgs.callPackage ./cliproxyapi-plus/package.nix {inherit sources;};
  discrawl = pkgs.callPackage ./discrawl/package.nix {inherit sources;};
  jcode = pkgs.callPackage ./jcode/package.nix {inherit sources;};
  lightpanda = pkgs.callPackage ./lightpanda/package.nix {inherit sources;};
  lumen = pkgs.callPackage ./lumen/package.nix {inherit sources;};
  pi-agent-rust = pkgs.callPackage ./pi-agent-rust/package.nix {inherit sources;};
  spotify-library-mcp = pkgs.callPackage ./spotify-library-mcp/package.nix {inherit sources;};
  wacli = pkgs.callPackage ./wacli/package.nix {inherit sources;};
  zai = pkgs.callPackage ./zai/package.nix {inherit sources;};
  zehn = pkgs.callPackage ./zehn/package.nix {inherit sources;};
  zerobrew-bin = pkgs.callPackage ./zerobrew-bin/package.nix {inherit sources;};
}
