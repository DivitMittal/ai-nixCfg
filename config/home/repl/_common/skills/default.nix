{lib}: let
  readSkill = (import ../lib.nix {inherit lib;}).readSkill;

  ## Skill metadata definitions
  skillMeta = {
    nix-flakes = {
      name = "nix-flakes";
      description = "Deep knowledge of Nix flakes. Use when working with flake.nix, inputs, or outputs.";
      # OpenCode specific
      compatibility = "opencode";
      metadata = {
        domain = "nix";
        expertise = "flakes";
      };
    };
    home-manager-modules = {
      name = "home-manager-modules";
      description = "Home Manager module patterns. Use when creating or modifying home-manager configs.";
      compatibility = "opencode";
      metadata = {
        domain = "nix";
        expertise = "home-manager";
      };
    };
    conventional-commits = {
      name = "conventional-commits";
      description = "Conventional Commits format. Use when creating commit messages.";
      compatibility = "opencode";
      metadata = {
        domain = "git";
        expertise = "commits";
      };
    };
  };

  skillNames = builtins.attrNames skillMeta;
in {
  inherit skillMeta skillNames readSkill;
}
