{pkgs}: let
  sources = pkgs.callPackage ../_sources/generated.nix {};
in
  {
    zoetrope = pkgs.callPackage ./zoetrope/package.nix {inherit sources;};
    cliproxyapi-plus = pkgs.callPackage ./cliproxyapi-plus/package.nix {inherit sources;};
    gowa = pkgs.callPackage ./gowa/package.nix {inherit sources;};
    jcode = pkgs.callPackage ./jcode/package.nix {inherit sources;};
    lightpanda = pkgs.callPackage ./lightpanda/package.nix {inherit sources;};
    pi-agent-rust = pkgs.callPackage ./pi-agent-rust/package.nix {inherit sources;};
    zai = pkgs.callPackage ./zai/package.nix {inherit sources;};
    zehn = pkgs.callPackage ./zehn/package.nix {inherit sources;};
  }
  // pkgs.lib.optionalAttrs (pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin") {
    lumen = pkgs.callPackage ./lumen/package.nix {inherit sources;};
  }
  // pkgs.lib.optionalAttrs pkgs.stdenvNoCC.hostPlatform.isDarwin {
    zerobrew-bin = pkgs.callPackage ./zerobrew-bin/package.nix {inherit sources;};
  }
