self: {
  imports = [
    ./cli
    ./repl
    ./cloud.nix
    ./mcp.nix
    ./workflows.nix
    self.homeManagerModules.default
  ];

  _module.args = {
    ai-nixCfg = self;
  };
}
