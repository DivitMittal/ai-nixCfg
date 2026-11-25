{pkgs}: let
  sources = pkgs.callPackage ../_sources/generated.nix {};
in
  {
    discrawl = pkgs.callPackage ./discrawl/package.nix {inherit sources;};
    elevenlabs-cli = pkgs.callPackage ./elevenlabs-cli/package.nix {inherit sources;};
    elevenlabs-skills = pkgs.callPackage ./elevenlabs-skills/package.nix {inherit sources;};
    higgsfield-cli = pkgs.callPackage ./higgsfield-cli/package.nix {inherit sources;};
    higgsfield-skills = pkgs.callPackage ./higgsfield-skills/package.nix {inherit sources;};
    spotify-library-mcp = pkgs.callPackage ./spotify-library-mcp/package.nix {inherit sources;};
    spotify-mcp-server = pkgs.callPackage ./spotify-mcp-server/package.nix {inherit sources;};
    wacli = pkgs.callPackage ./wacli/package.nix {inherit sources;};
    zoetrope = pkgs.callPackage ./zoetrope/package.nix {inherit sources;};
    cliproxyapi-plus = pkgs.callPackage ./cliproxyapi-plus/package.nix {inherit sources;};
    jcode = pkgs.callPackage ./jcode/package.nix {inherit sources;};
    lightpanda = pkgs.callPackage ./lightpanda/package.nix {inherit sources;};
    pi-agent-rust = pkgs.callPackage ./pi-agent-rust/package.nix {inherit sources;};
    zai = pkgs.callPackage ./zai/package.nix {inherit sources;};
    zehn = pkgs.callPackage ./zehn/package.nix {inherit sources;};
  }
  // pkgs.lib.optionalAttrs (pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin") {
    antigravity-cli = pkgs.callPackage ./antigravity-cli/package.nix {};
    lumen = pkgs.callPackage ./lumen/package.nix {inherit sources;};
  }
  // pkgs.lib.optionalAttrs pkgs.stdenvNoCC.hostPlatform.isDarwin {
    zerobrew-bin = pkgs.callPackage ./zerobrew-bin/package.nix {inherit sources;};
  }
