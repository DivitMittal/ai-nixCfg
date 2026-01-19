{customLib, ...}: {
  flake.homeManagerModules = {
    default = import ./home {inherit customLib;};
    claude-code = import ./home/claude-code.nix;
    codex = import ./home/codex.nix;
    crush = import ./home/crush.nix;
    github-copilot = import ./home/github-copilot.nix;
  };
}
