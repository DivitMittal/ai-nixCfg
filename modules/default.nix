{inputs, ...}: {
  flake.homeManagerModules = {
    ## Default Import for all modules
    default = {
      _module.args.llm-agents = inputs.llm-agents;
      _module.args.talon-nix = inputs.talon-nix;
      _module.args.talon-community = inputs.talon-community;
      imports = [(inputs.import-tree ./home)];
    };

    ## Individual imports (for selective usage)
    ccs = import ./home/ccs.nix;
    codex = import ./home/codex.nix;
    crush = import ./home/crush.nix;
    n8n = import ./home/n8n.nix;
    talon = {
      _module.args.talon-nix = inputs.talon-nix;
      _module.args.talon-community = inputs.talon-community;
      imports = [./home/talon.nix];
    };
    workmux = {
      _module.args.llm-agents = inputs.llm-agents;
      imports = [./home/workmux.nix];
    };
    herdr = {
      _module.args.llm-agents = inputs.llm-agents;
      imports = [./home/herdr.nix];
    };
    agent-deck = {
      _module.args.llm-agents = inputs.llm-agents;
      imports = [./home/agent-deck.nix];
    };
  };
}
