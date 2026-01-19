_: {
  programs.gemini-cli.commands = {
    ## Git workflows
    commit = {
      description = "Create git commit(s) with proper message(s)";
      prompt = builtins.readFile ./commands/commit.md;
    };

    pr = {
      description = "Create a pull request with description";
      prompt = builtins.readFile ./commands/pr.md;
    };

    changelog = {
      description = "Update CHANGELOG.md with new entry";
      prompt = builtins.readFile ./commands/changelog.md;
    };

    fix-issue = {
      description = "Fix a GitHub issue";
      prompt = builtins.readFile ./commands/fix-issue.md;
    };

    ## Code quality
    review = {
      description = "Review code for issues";
      prompt = builtins.readFile ./commands/review.md;
    };

    refactor = {
      description = "Refactor code while preserving behavior";
      prompt = builtins.readFile ./commands/refactor.md;
    };

    human-code-refactor = {
      description = "Refactor code to appear human-written by eliminating AI/LLM telltale patterns";
      prompt = builtins.readFile ./commands/human-code-refactor.md;
    };

    ## Documentation
    explain = {
      description = "Explain code in detail";
      prompt = builtins.readFile ./commands/explain.md;
    };

    doc = {
      description = "Generate or improve documentation";
      prompt = builtins.readFile ./commands/doc.md;
    };

    ## Quick actions
    test = {
      description = "Run project tests";
      prompt = builtins.readFile ./commands/test.md;
    };

    build = {
      description = "Build the project";
      prompt = builtins.readFile ./commands/build.md;
    };

    clean = {
      description = "Clean build artifacts and caches";
      prompt = builtins.readFile ./commands/clean.md;
    };
  };
}
