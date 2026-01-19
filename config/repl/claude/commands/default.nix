_: {
  programs.claude-code.commands = {
    ## Git workflows
    commit = builtins.readFile ./commit.md;
    pr = builtins.readFile ./pr.md;
    changelog = builtins.readFile ./changelog.md;
    fix-issue = builtins.readFile ./fix-issue.md;

    ## Code quality
    review = builtins.readFile ./review.md;
    refactor = builtins.readFile ./refactor.md;
    human-code-refactor = builtins.readFile ./human-code-refactor.md;

    ## Documentation
    explain = builtins.readFile ./explain.md;
    doc = builtins.readFile ./doc.md;

    ## Quick actions
    test = builtins.readFile ./test.md;
    build = builtins.readFile ./build.md;
    clean = builtins.readFile ./clean.md;
  };
}
