_: {
  flake.homeManagerModules = {
    claude-code = import ./home/claude-code.nix;
    codex = import ./home/codex.nix;
    github-copilot = import ./home/github-copilot.nix;

    Cfg = import ../config;
  };
}
