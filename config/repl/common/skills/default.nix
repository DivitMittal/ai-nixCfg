{lib}: let
  inherit (import ../lib.nix {inherit lib;}) readSkill mkYamlFrontmatter;

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

  ## Tool-specific skill generators
  mkClaudeSkill = name: let
    meta = skillMeta.${name};
    body = readSkill name;
    frontmatter = {inherit (meta) name description;};
  in
    mkYamlFrontmatter frontmatter + body;

  mkCodexSkill = name: let
    meta = skillMeta.${name};
    body = readSkill name;
    frontmatter = {inherit (meta) name description;};
  in
    mkYamlFrontmatter frontmatter + body;

  mkOpenCodeSkill = name: let
    meta = skillMeta.${name};
    body = readSkill name;
    frontmatter =
      {inherit (meta) name description;}
      // lib.optionalAttrs (meta ? compatibility) {inherit (meta) compatibility;}
      // lib.optionalAttrs (meta ? metadata) {inherit (meta) metadata;};
  in
    mkYamlFrontmatter frontmatter + body;
in {
  inherit skillMeta mkClaudeSkill mkCodexSkill mkOpenCodeSkill;

  ## Pre-generated skill sets
  claude.skills = lib.genAttrs skillNames mkClaudeSkill;
  codex.skills = lib.genAttrs skillNames mkCodexSkill;
  opencode.skills = lib.genAttrs skillNames mkOpenCodeSkill;
}
