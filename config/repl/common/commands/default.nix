{lib}: let
  inherit (import ../lib.nix {inherit lib;}) readCommand mkYamlFrontmatter;

  ## Command metadata definitions
  commandMeta = {
    commit = {
      description = "Create git commit(s) with proper message(s)";
      argument-hint = "[message-hint]";
      # Claude/Crush specific
      allowed-tools = "Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*)";
      # Copilot specific
      tools = ["terminal"];
    };
    pr = {
      description = "Create a pull request with description";
      argument-hint = "[title]";
      allowed-tools = "Bash(git:*), Bash(gh:*)";
      tools = ["terminal"];
    };
    changelog = {
      description = "Update CHANGELOG.md with new entry";
      argument-hint = "[version]";
      allowed-tools = "Bash(git log:*), Bash(git diff:*), Read, Edit";
      tools = ["terminal" "codebase" "editFiles"];
    };
    fix-issue = {
      description = "Fix a GitHub issue";
      argument-hint = "<issue-number>";
      allowed-tools = "Bash(gh:*), Bash(git:*), Read, Edit, Write";
      tools = ["terminal" "codebase" "editFiles" "createFiles"];
    };
    review = {
      description = "Review code for issues";
      argument-hint = "[file-or-path]";
      allowed-tools = "Read, Grep, Glob, Bash(git diff:*)";
      tools = ["codebase" "terminal"];
    };
    refactor = {
      description = "Refactor code while preserving behavior";
      argument-hint = "<file-or-symbol>";
      allowed-tools = "Read, Edit, Write, Grep, Glob";
      tools = ["codebase" "editFiles"];
    };
    human-code-refactor = {
      description = "Refactor code to appear human-written by eliminating AI/LLM telltale patterns";
      argument-hint = "<file-or-symbol>";
      allowed-tools = "Read, Edit, Write, Grep, Glob";
      tools = ["codebase" "editFiles"];
    };
    explain = {
      description = "Explain code in detail";
      argument-hint = "<file-or-symbol>";
      allowed-tools = "Read, Grep";
      tools = ["codebase"];
    };
    doc = {
      description = "Generate or improve documentation";
      argument-hint = "<file-or-symbol>";
      allowed-tools = "Read, Edit, Write";
      tools = ["codebase" "editFiles"];
    };
    test = {
      description = "Run project tests";
      allowed-tools = "Bash(nix:*), Bash(npm:*), Bash(pytest:*), Bash(cargo:*)";
      tools = ["terminal"];
    };
    build = {
      description = "Build the project";
      allowed-tools = "Bash(nix:*), Bash(npm:*), Bash(cargo:*)";
      tools = ["terminal"];
    };
    clean = {
      description = "Clean build artifacts and caches";
      allowed-tools = "Bash(git:*), Bash(rm:*), Bash(nix:*)";
      tools = ["terminal"];
    };
  };

  commandNames = builtins.attrNames commandMeta;

  ## Tool-specific command generators
  mkClaudeCommand = name: let
    meta = commandMeta.${name};
    body = readCommand name;
    frontmatter =
      {inherit (meta) description;}
      // lib.optionalAttrs (meta ? allowed-tools) {inherit (meta) allowed-tools;}
      // lib.optionalAttrs (meta ? argument-hint) {inherit (meta) argument-hint;};
  in
    mkYamlFrontmatter frontmatter + body;

  mkCodexPrompt = name: let
    meta = commandMeta.${name};
    body = readCommand name;
    frontmatter =
      {inherit (meta) description;}
      // lib.optionalAttrs (meta ? argument-hint) {inherit (meta) argument-hint;};
  in
    mkYamlFrontmatter frontmatter + body;

  mkCopilotCommand = name: let
    meta = commandMeta.${name};
    body = readCommand name;
    frontmatter =
      {inherit (meta) description;}
      // lib.optionalAttrs (meta ? argument-hint) {inherit (meta) argument-hint;}
      // lib.optionalAttrs (meta ? tools) {inherit (meta) tools;};
  in
    mkYamlFrontmatter frontmatter + body;

  mkGeminiCommand = name: let
    meta = commandMeta.${name};
    body = readCommand name;
  in {
    inherit (meta) description;
    prompt = body;
  };

  mkOpenCodeCommand = name: let
    meta = commandMeta.${name};
    body = readCommand name;
    frontmatter = {inherit (meta) description;};
  in
    mkYamlFrontmatter frontmatter + body;
in {
  inherit commandMeta mkClaudeCommand mkCodexPrompt mkCopilotCommand mkGeminiCommand mkOpenCodeCommand;

  ## Pre-generated command sets
  claude.commands = lib.genAttrs commandNames mkClaudeCommand;
  codex.prompts = lib.genAttrs commandNames mkCodexPrompt;
  copilot.commands = lib.genAttrs commandNames mkCopilotCommand;
  gemini.commands = lib.genAttrs commandNames mkGeminiCommand;
  opencode.commands = lib.genAttrs commandNames mkOpenCodeCommand;
  crush.commands = lib.genAttrs commandNames mkClaudeCommand; # Same format as Claude
}
