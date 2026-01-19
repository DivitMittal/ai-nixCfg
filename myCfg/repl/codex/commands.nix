_: {
  programs.codex.prompts = {
    ## Git workflows
    commit = builtins.readFile ../claude/commands/commit.md;
    pr = builtins.readFile ../claude/commands/pr.md;
    changelog = builtins.readFile ../claude/commands/changelog.md;
    fix-issue = builtins.readFile ../claude/commands/fix-issue.md;

    ## Code quality
    review = builtins.readFile ../claude/commands/review.md;
    refactor = builtins.readFile ../claude/commands/refactor.md;
    human-code-refactor = builtins.readFile ../claude/commands/human-code-refactor.md;

    ## Documentation
    explain = builtins.readFile ../claude/commands/explain.md;
    doc = builtins.readFile ../claude/commands/doc.md;

    ## Quick actions
    test = builtins.readFile ../claude/commands/test.md;
    build = builtins.readFile ../claude/commands/build.md;
    clean = builtins.readFile ../claude/commands/clean.md;
  };
}
