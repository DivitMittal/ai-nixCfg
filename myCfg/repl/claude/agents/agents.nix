_: {
  programs.claude-code.agents = {
    nix-expert = import ./nix-expert.nix;
    code-reviewer = import ./code-reviewer.nix;
    security-auditor = import ./security-auditor.nix;
    test-writer = import ./test-writer.nix;
  };
}
