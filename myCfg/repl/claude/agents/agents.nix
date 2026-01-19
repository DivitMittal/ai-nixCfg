_: {
  programs.claude-code.agents = {
    nix-expert = {
      name = "nix-expert";
      description = "MUST BE USED for Nix/NixOS configuration, flakes, and derivations";
      model = "sonnet";
      tools = ["Read" "Write" "Edit" "Grep" "Glob" "Bash"];
      prompt = builtins.readFile ./nix-expert.md;
    };
    code-reviewer = {
      name = "code-reviewer";
      description = "Use PROACTIVELY for code reviews and PR analysis";
      model = "sonnet";
      tools = ["Read" "Grep" "Glob"];
      prompt = builtins.readFile ./code-reviewer.md;
    };
    security-auditor = {
      name = "security-auditor";
      description = "MUST BE USED for security reviews and vulnerability assessment";
      model = "opus";
      tools = ["Read" "Grep" "Glob"];
      prompt = builtins.readFile ./security-auditor.md;
    };
    test-writer = {
      name = "test-writer";
      description = "Use when writing or improving tests";
      model = "sonnet";
      tools = ["Read" "Write" "Edit" "Grep" "Bash"];
      prompt = builtins.readFile ./test-writer.md;
    };
  };
}
