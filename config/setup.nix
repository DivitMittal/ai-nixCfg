self: {
  imports = [
    (self.inputs.import-tree ./home)
    self.homeManagerModules.default
    self.inputs.nix-openclaw.homeManagerModules.openclaw
  ];

  _module.args = {
    ai-nixCfg = self;
  };
}
