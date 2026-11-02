{pkgs}: let
  sources = pkgs.callPackage ../_sources/generated.nix {};
  isX86Darwin = pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin";
in
  {
    cliproxyapi-plus = pkgs.callPackage ./cliproxyapi-plus/package.nix {inherit sources;};
    gowa = pkgs.callPackage ./gowa/package.nix {inherit sources;};
    jcode = pkgs.callPackage ./jcode/package.nix {inherit sources;};
    lightpanda = pkgs.callPackage ./lightpanda/package.nix {inherit sources;};
    lumen = pkgs.callPackage ./lumen/package.nix {inherit sources;};
    pi-agent-rust = pkgs.callPackage ./pi-agent-rust/package.nix {inherit sources;};
    zai = pkgs.callPackage ./zai/package.nix {inherit sources;};
    zehn = pkgs.callPackage ./zehn/package.nix {inherit sources;};
    zerostack = pkgs.callPackage ./zerostack/package.nix {inherit sources;};
  }
  // pkgs.lib.optionalAttrs pkgs.stdenvNoCC.hostPlatform.isDarwin {
    zerobrew-bin = pkgs.callPackage ./zerobrew-bin/package.nix {inherit sources;};
  }
  ## llm-agents.nix covers every other system (and wins in pkgs/default.nix) but
  ## has no x86_64-darwin packages.
  // pkgs.lib.optionalAttrs isX86Darwin {
    antigravity-cli = pkgs.callPackage ./antigravity-cli/package.nix {inherit sources;};
    cursor-agent = pkgs.callPackage ./cursor-agent/package.nix {inherit sources;};
  }
