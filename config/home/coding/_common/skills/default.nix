{lib}: let
  inherit ((import ../lib.nix {inherit lib;})) readSkill;

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
    dossier = {
      name = "dossier";
      description = "The user's global memory of people, organisations and open matters (job leads, business deals, lawyers, admin) kept in the Dossier vault. Use when the user asks to log or remember a conversation, says they just spoke with someone, pastes a chat or email to file, asks what they know about a person or company, wants a brief before a call, or asks for a dossier review. Not for project or coding context.";
    };
    herdr = {
      name = "herdr";
      description = "Control Herdr, a terminal multiplexer for coding agents. Use only when the user explicitly mentions Herdr or asks to use Herdr to inspect or control panes, tabs, workspaces, terminals, commands, or communication with another agent. Do not use merely because a task could benefit from a background terminal, delegation, or parallel work. Requires HERDR_ENV=1.";
    };
  };

  skillNames = builtins.attrNames skillMeta;
in {
  inherit skillMeta skillNames readSkill;
}
