{inputs, ...}: {
  flake.homeManagerModules = {
    ## Default Import for all modules
    default = {
      _module.args.llm-agents = inputs.llm-agents;
      imports = [(inputs.import-tree ./home)];
    };

    ## Individual imports (for selective usage)
    ccs = import ./home/ccs.nix;
    codex = import ./home/codex.nix;
    crush = import ./home/crush.nix;
    n8n = import ./home/n8n.nix;
    herdr = {
      _module.args.llm-agents = inputs.llm-agents;
      imports = [./home/herdr.nix];
    };
  };
}
