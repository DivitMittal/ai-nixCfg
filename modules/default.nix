{inputs, ...}: {
  flake.homeManagerModules = {
    ## Default Import for all modules
    default = inputs.import-tree ./home;

    ## Individual imports (for selective usage)
    claude-code = import ./home/claude-code.nix;
    codex = import ./home/codex.nix;
    crush = import ./home/crush.nix;
    github-copilot = import ./home/github-copilot.nix;
  };
}
