_: {
  flake.homeManagerModules = {
    default = import ./home;
    claude-code = import ./home/claude-code.nix;
    codex = import ./home/codex.nix;
    github-copilot = import ./home/github-copilot.nix;
  };
}
