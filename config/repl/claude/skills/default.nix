_: {
  programs.claude-code.skills = {
    nix-flakes = builtins.readFile ./nix-flakes.md;
    home-manager-modules = builtins.readFile ./home-manager-modules.md;
    conventional-commits = builtins.readFile ./conventional-commits.md;
  };
}
