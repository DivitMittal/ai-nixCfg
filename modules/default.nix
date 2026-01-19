{
  customLib,
  self,
  ...
}: {
  flake.homeManagerModules = {
    default = import customLib.scanPaths ./.;
    claude-code = import ./home/claude-code.nix;
    codex = import ./home/codex.nix;
    crush = import ./home/crush.nix;
    github-copilot = import ./home/github-copilot.nix;

    Cfg = import ../config self;
  };
}
