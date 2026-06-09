{inputs, ...}: {
  flake.homeManagerModules = {
    ## Default Import for all modules
    default = inputs.import-tree ./home;

    ## Individual imports (for selective usage)
    ccs = import ./home/ccs.nix;
    codex = import ./home/codex.nix;
    crush = import ./home/crush.nix;
    hermes-agent = import ./home/hermes-agent.nix;
    n8n = import ./home/n8n.nix;
    openclaw = import ./home/openclaw.nix;
  };
}
