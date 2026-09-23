self: let
  customLib =
    (import (self.inputs.OS-nixCfg + "/lib/custom.nix") {inherit (self.inputs.nixpkgs) lib;})
    // {
      ## bun x <pkg> — faster JS/npm runner, preferred tier 1 in the
      ## bunx>pnpmx>uvx>zbx>brew x86_64-darwin fallback cascade.
      mkBunxBin = pkgs: name: pkg:
        pkgs.writeShellScriptBin name ''exec ${pkgs.bun}/bin/bun x ${pkg} "$@"'';
      ## Local variant of OS-nixCfg's mkZbxBin: that one hardcodes
      ## pkgs.customDarwin.zerobrew-bin, an overlay attr this repo doesn't have.
      ## Takes the zerobrew package and target binary name explicitly instead,
      ## since a Homebrew formula's name doesn't always match its binary
      ## (e.g. formula `gastown` installs binary `gt`).
      mkZbxBin = pkgs: zerobrewPkg: formula: binName:
        pkgs.writeShellScriptBin binName ''exec ${zerobrewPkg}/bin/zbx ${formula} "$@"'';
    };
in {
  imports = [
    (self.inputs.import-tree ./home)
    self.homeManagerModules.default
    self.inputs.nix-openclaw.homeManagerModules.openclaw
    self.inputs.hermes-agent-hm.homeManagerModules.default
    self.inputs.pi-nix.homeManagerModules.default
  ];

  _module.args = {
    ai-nixCfg = self;
    inherit customLib;
  };
}
