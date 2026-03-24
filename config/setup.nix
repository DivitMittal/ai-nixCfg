self: {
  imports = [
    ./cli
    ./repl
    ./cloud.nix
    ./mcp.nix
    ./workflows.nix
    self.homeManagerModules.default
    self.inputs.nix-openclaw.homeManagerModules.openclaw
  ];

  _module.args = {
    ai-nixCfg = self;
  };
}
