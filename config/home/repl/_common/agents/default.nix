{lib}: let
  readAgent = (import ../lib.nix {inherit lib;}).readAgent;

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
in {
  inherit agentMeta agentNames readAgent;
}
