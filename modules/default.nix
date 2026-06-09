{inputs, ...}: {
  flake.homeManagerModules = {
    ## Default Import for all modules
    default = inputs.import-tree ./home;

    ## Individual imports (for selective usage)
    ccs = import ./home/claude-code.nix;
    codex = import ./home/codex.nix;
    crush = import ./home/crush.nix;
    hermes-agent = import ./home/hermes-agent.nix;
    openclaw = import ./home/openclaw.nix;
  };
}
