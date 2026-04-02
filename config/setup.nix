self: {
  imports = [
    (self.inputs."import-tree".matchNot ".*(setup|default)\\.nix" ./.)
    self.homeManagerModules.default
    self.inputs.nix-openclaw.homeManagerModules.openclaw
  ];

  _module.args = {
    ai-nixCfg = self;
  };
}
