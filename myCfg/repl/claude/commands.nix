_: {
  programs.claude-code.commands = {
    ## Git workflows
    commit = builtins.readFile ./commands/commit.md;
    pr = builtins.readFile ./commands/pr.md;
    changelog = builtins.readFile ./commands/changelog.md;
    fix-issue = builtins.readFile ./commands/fix-issue.md;

    ## Code quality
    review = builtins.readFile ./commands/review.md;
    refactor = builtins.readFile ./commands/refactor.md;
    human-code-refactor = builtins.readFile ./commands/human-code-refactor.md;

    ## Documentation
    explain = builtins.readFile ./commands/explain.md;
    doc = builtins.readFile ./commands/doc.md;

    ## Quick actions
    test = builtins.readFile ./commands/test.md;
    build = builtins.readFile ./commands/build.md;
    clean = builtins.readFile ./commands/clean.md;
  };
}
