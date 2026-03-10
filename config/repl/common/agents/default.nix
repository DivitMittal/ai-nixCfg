{lib}: let
  inherit (import ../lib.nix {inherit lib;}) readAgent mkYamlFrontmatter;

  ## Agent metadata definitions
  agentMeta = {
    code-reviewer = {
      name = "code-reviewer";
      description = "Use PROACTIVELY for code reviews and PR analysis";
      # Claude specific
      model = "sonnet";
      tools = "Read, Grep, Glob";
      # Copilot specific
      copilot-tools = ["read" "search"];
      # OpenCode specific
      opencode-mode = "subagent";
      opencode-tools = {
        write = false;
        edit = false;
      };
    };
    nix-expert = {
      name = "nix-expert";
      description = "MUST BE USED for Nix/NixOS configuration, flakes, and derivations";
      model = "sonnet";
      tools = "Read, Write, Edit, Grep, Glob, Bash";
      copilot-tools = ["read" "search" "edit" "terminal"];
      opencode-mode = "subagent";
      opencode-tools = {};
    };
    security-auditor = {
      name = "security-auditor";
      description = "MUST BE USED for security reviews and vulnerability assessment";
      model = "opus";
      tools = "Read, Grep, Glob";
      copilot-tools = ["read" "search"];
      opencode-mode = "subagent";
      opencode-tools = {
        write = false;
        edit = false;
        bash = false;
      };
    };
    test-writer = {
      name = "test-writer";
      description = "Use when writing or improving tests";
      model = "sonnet";
      tools = "Read, Write, Edit, Grep, Bash";
      copilot-tools = ["read" "search" "edit" "terminal"];
      opencode-mode = "subagent";
      opencode-tools = {};
    };
  };

  agentNames = builtins.attrNames agentMeta;

  ## Tool-specific agent generators
  mkClaudeAgent = name: let
    meta = agentMeta.${name};
    body = readAgent name;
    frontmatter = {
      inherit (meta) name description model;
      inherit (meta) tools;
    };
  in
    mkYamlFrontmatter frontmatter + body;

  mkCopilotAgent = name: let
    meta = agentMeta.${name};
    body = readAgent name;
    frontmatter = {
      inherit (meta) name description;
      tools = meta.copilot-tools;
    };
  in
    mkYamlFrontmatter frontmatter + body;

  mkOpenCodeAgent = name: let
    meta = agentMeta.${name};
    body = readAgent name;
    # OpenCode uses different frontmatter format
    formatTools = tools:
      if tools == {}
      then ""
      else
        "\ntools:"
        + lib.concatStrings (lib.mapAttrsToList (k: v: "\n  ${k}: ${
            if v
            then "true"
            else "false"
          }")
          tools);
    frontmatter = ''
      ---
      description: ${meta.description}
      mode: ${meta.opencode-mode}${formatTools meta.opencode-tools}
      ---
    '';
  in
    frontmatter + body;
in {
  inherit agentMeta mkClaudeAgent mkCopilotAgent mkOpenCodeAgent;

  ## Pre-generated agent sets
  claude.agents = lib.genAttrs agentNames mkClaudeAgent;
  copilot.agents = lib.genAttrs agentNames mkCopilotAgent;
  opencode.agents = lib.genAttrs agentNames mkOpenCodeAgent;
}
