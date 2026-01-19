_: let
  claudeCommands = ../claude/commands;
in {
  programs.gemini-cli.commands = {
    ## Git workflows
    commit = {
      description = "Create git commit(s) with proper message(s)";
      prompt = builtins.readFile "${claudeCommands}/commit.md";
    };

    pr = {
      description = "Create a pull request with description";
      prompt = builtins.readFile "${claudeCommands}/pr.md";
    };

    changelog = {
      description = "Update CHANGELOG.md with new entry";
      prompt = builtins.readFile "${claudeCommands}/changelog.md";
    };

    fix-issue = {
      description = "Fix a GitHub issue";
      prompt = builtins.readFile "${claudeCommands}/fix-issue.md";
    };

    ## Code quality
    review = {
      description = "Review code for issues";
      prompt = builtins.readFile "${claudeCommands}/review.md";
    };

    refactor = {
      description = "Refactor code while preserving behavior";
      prompt = builtins.readFile "${claudeCommands}/refactor.md";
    };

    human-code-refactor = {
      description = "Refactor code to appear human-written by eliminating AI/LLM telltale patterns";
      prompt = builtins.readFile "${claudeCommands}/human-code-refactor.md";
    };

    ## Documentation
    explain = {
      description = "Explain code in detail";
      prompt = builtins.readFile "${claudeCommands}/explain.md";
    };

    doc = {
      description = "Generate or improve documentation";
      prompt = builtins.readFile "${claudeCommands}/doc.md";
    };

    ## Quick actions
    test = {
      description = "Run project tests";
      prompt = builtins.readFile "${claudeCommands}/test.md";
    };

    build = {
      description = "Build the project";
      prompt = builtins.readFile "${claudeCommands}/build.md";
    };

    clean = {
      description = "Clean build artifacts and caches";
      prompt = builtins.readFile "${claudeCommands}/clean.md";
    };
  };
}
