_: let
  claudeCommands = ../claude/commands;
in {
  programs.crush.commands = {
    ## Git workflows
    commit = builtins.readFile "${claudeCommands}/commit.md";
    pr = builtins.readFile "${claudeCommands}/pr.md";
    changelog = builtins.readFile "${claudeCommands}/changelog.md";
    fix-issue = builtins.readFile "${claudeCommands}/fix-issue.md";

    ## Code quality
    review = builtins.readFile "${claudeCommands}/review.md";
    refactor = builtins.readFile "${claudeCommands}/refactor.md";
    human-code-refactor = builtins.readFile "${claudeCommands}/human-code-refactor.md";

    ## Documentation
    explain = builtins.readFile "${claudeCommands}/explain.md";
    doc = builtins.readFile "${claudeCommands}/doc.md";

    ## Quick actions
    test = builtins.readFile "${claudeCommands}/test.md";
    build = builtins.readFile "${claudeCommands}/build.md";
    clean = builtins.readFile "${claudeCommands}/clean.md";
  };
}
