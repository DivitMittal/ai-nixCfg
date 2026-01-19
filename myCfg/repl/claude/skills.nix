_: {
  programs.claude-code.skills = {
    nix-flakes = builtins.readFile ./skills/nix-flakes.md;
    home-manager-modules = builtins.readFile ./skills/home-manager-modules.md;
    conventional-commits = builtins.readFile ./skills/conventional-commits.md;
  };
}
