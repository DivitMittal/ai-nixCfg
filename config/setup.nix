self: {
  imports = [
    (self.inputs."import-tree".matchNot "setup\\.nix|.*(default|lib)\\.nix" ./.)
    self.homeManagerModules.default
    self.inputs.nix-openclaw.homeManagerModules.openclaw
  ];

  _module.args = {
    ai-nixCfg = self;
  };
}
