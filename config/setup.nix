self: let
  customLib = import (self.inputs.OS-nixCfg + "/lib/custom.nix") {inherit (self.inputs.nixpkgs) lib;};
in {
  imports = [
    (self.inputs.import-tree ./home)
    self.homeManagerModules.default
    self.inputs.nix-openclaw.homeManagerModules.openclaw
    self.inputs.hermes-agent-hm.homeManagerModules.default
  ];

  _module.args = {
    ai-nixCfg = self;
    inherit customLib;
  };
}
