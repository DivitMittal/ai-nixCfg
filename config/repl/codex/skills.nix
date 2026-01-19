_: {
  programs.codex.skills = {
    nix-flakes = builtins.readFile ../claude/skills/nix-flakes.md;
    home-manager-modules = builtins.readFile ../claude/skills/home-manager-modules.md;
    conventional-commits = builtins.readFile ../claude/skills/conventional-commits.md;
  };
}
