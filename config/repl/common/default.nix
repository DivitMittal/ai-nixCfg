# Common content and frontmatter definitions for AI CLI tools
{lib, ...}: let
  # Read common content files
  commandsDir = ./commands;
  skillsDir = ./skills;
  agentsDir = ./agents;
  rulesDir = ./rules;

  readCommand = name: builtins.readFile "${commandsDir}/${name}.md";
  readSkill = name: builtins.readFile "${skillsDir}/${name}.md";
  readAgent = name: builtins.readFile "${agentsDir}/${name}.md";
  readRule = name: builtins.readFile "${rulesDir}/${name}.md";

  # Rule names (derived from directory contents)
  ruleNames = ["git-workflow" "security" "documentation" "code-quality"];

  # Memory/rule loading instruction (shared across tools)
  memoryInstruction = ''
    ## External File Loading

    CRITICAL: When you encounter a file reference (e.g., @rules/general.md), use your Read tool to load it on a need-to-know basis. They're relevant to the SPECIFIC task at hand.

    Instructions:

    - Do NOT preemptively load all references - use lazy loading based on actual need
    - When loaded, treat content as mandatory instructions that override defaults
    - Follow references recursively when needed
  '';

  # Command metadata definitions
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

  # Skill metadata definitions
  skillMeta = {
    nix-flakes = {
      name = "nix-flakes";
      description = "Deep knowledge of Nix flakes. Use when working with flake.nix, inputs, or outputs.";
      # OpenCode specific
      compatibility = "opencode";
      metadata = {
        domain = "nix";
        expertise = "flakes";
      };
    };
    home-manager-modules = {
      name = "home-manager-modules";
      description = "Home Manager module patterns. Use when creating or modifying home-manager configs.";
      compatibility = "opencode";
      metadata = {
        domain = "nix";
        expertise = "home-manager";
      };
    };
    conventional-commits = {
      name = "conventional-commits";
      description = "Conventional Commits format. Use when creating commit messages.";
      compatibility = "opencode";
      metadata = {
        domain = "git";
        expertise = "commits";
      };
    };
  };

  # Agent metadata definitions
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

  # YAML frontmatter generator
  mkYamlFrontmatter = attrs: let
    formatValue = v:
      if builtins.isList v
      then "[${lib.concatMapStringsSep ", " (x: "\"${x}\"") v}]"
      else if builtins.isAttrs v
      then "\n${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: val: "  ${k}: ${val}") v)}"
      else v;
    lines = lib.mapAttrsToList (k: v: "${k}: ${formatValue v}") attrs;
  in "---\n${lib.concatStringsSep "\n" lines}\n---\n";

  # TOML generator for Gemini
  mkToml = attrs: let
    formatValue = v:
      if builtins.isString v
      then
        if lib.hasInfix "\n" v
        then ''"""\n${v}"""''
        else ''"${v}"''
      else toString v;
  in
    lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k} = ${formatValue v}") attrs);

  # Tool-specific command generators
  mkClaudeCommand = name: let
    meta = commandMeta.${name};
    body = readCommand name;
    frontmatter =
      {inherit (meta) description;}
      // lib.optionalAttrs (meta ? allowed-tools) {allowed-tools = meta.allowed-tools;}
      // lib.optionalAttrs (meta ? argument-hint) {argument-hint = meta.argument-hint;};
  in
    mkYamlFrontmatter frontmatter + body;

  mkCodexPrompt = name: let
    meta = commandMeta.${name};
    body = readCommand name;
    frontmatter =
      {inherit (meta) description;}
      // lib.optionalAttrs (meta ? argument-hint) {argument-hint = meta.argument-hint;};
  in
    mkYamlFrontmatter frontmatter + body;

  mkCopilotCommand = name: let
    meta = commandMeta.${name};
    body = readCommand name;
    frontmatter =
      {inherit (meta) description;}
      // lib.optionalAttrs (meta ? argument-hint) {argument-hint = meta.argument-hint;}
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

  # Tool-specific skill generators
  mkClaudeSkill = name: let
    meta = skillMeta.${name};
    body = readSkill name;
    frontmatter = {inherit (meta) name description;};
  in
    mkYamlFrontmatter frontmatter + body;

  mkCodexSkill = name: let
    meta = skillMeta.${name};
    body = readSkill name;
    frontmatter = {inherit (meta) name description;};
  in
    mkYamlFrontmatter frontmatter + body;

  mkOpenCodeSkill = name: let
    meta = skillMeta.${name};
    body = readSkill name;
    frontmatter =
      {inherit (meta) name description;}
      // lib.optionalAttrs (meta ? compatibility) {inherit (meta) compatibility;}
      // lib.optionalAttrs (meta ? metadata) {inherit (meta) metadata;};
  in
    mkYamlFrontmatter frontmatter + body;

  # Tool-specific agent generators
  mkClaudeAgent = name: let
    meta = agentMeta.${name};
    body = readAgent name;
    frontmatter = {
      inherit (meta) name description model;
      tools = meta.tools;
    };
  in
    mkYamlFrontmatter frontmatter + body;

  mkCopilotAgent = name: let
    meta = agentMeta.${name};
    body = readAgent name;
    frontmatter = {
      inherit (meta) name description;
      tools = meta.copilot-tools;
    };
  in
    mkYamlFrontmatter frontmatter + body;

  mkOpenCodeAgent = name: let
    meta = agentMeta.${name};
    body = readAgent name;
    # OpenCode uses different frontmatter format
    formatTools = tools:
      if tools == {}
      then ""
      else
        "\ntools:" + lib.concatStrings (lib.mapAttrsToList (k: v: "\n  ${k}: ${
          if v
          then "true"
          else "false"
        }") tools);
    frontmatter = ''
      ---
      description: ${meta.description}
      mode: ${meta.opencode-mode}${formatTools meta.opencode-tools}
      ---
    '';
  in
    frontmatter + body;

  # Generate all commands for each tool
  commandNames = builtins.attrNames commandMeta;
  skillNames = builtins.attrNames skillMeta;
  agentNames = builtins.attrNames agentMeta;
in {
  # Export metadata for reference
  inherit commandMeta skillMeta agentMeta;

  # Export generators
  inherit
    mkClaudeCommand
    mkCodexPrompt
    mkCopilotCommand
    mkGeminiCommand
    mkOpenCodeCommand
    mkClaudeSkill
    mkCodexSkill
    mkOpenCodeSkill
    mkClaudeAgent
    mkCopilotAgent
    mkOpenCodeAgent
    ;

  # Pre-generated command sets
  claude.commands = lib.genAttrs commandNames mkClaudeCommand;
  codex.prompts = lib.genAttrs commandNames mkCodexPrompt;
  copilot.commands = lib.genAttrs commandNames mkCopilotCommand;
  gemini.commands = lib.genAttrs commandNames mkGeminiCommand;
  opencode.commands = lib.genAttrs commandNames mkOpenCodeCommand;
  crush.commands = lib.genAttrs commandNames mkClaudeCommand; # Same format as Claude

  # Pre-generated skill sets
  claude.skills = lib.genAttrs skillNames mkClaudeSkill;
  codex.skills = lib.genAttrs skillNames mkCodexSkill;
  opencode.skills = lib.genAttrs skillNames mkOpenCodeSkill;

  # Pre-generated agent sets
  claude.agents = lib.genAttrs agentNames mkClaudeAgent;
  copilot.agents = lib.genAttrs agentNames mkCopilotAgent;
  opencode.agents = lib.genAttrs agentNames mkOpenCodeAgent;

  # Rule generators
  # Claude: individual rules as attrset
  claude.rules = lib.genAttrs ruleNames readRule;

  # Codex/OpenCode: combined rules with separator
  combinedRules = lib.concatStringsSep "\n\n---\n\n" (map readRule ruleNames);
  codex.rules = memoryInstruction + "\n\n" + combinedRules;
  opencode.rules = memoryInstruction + "\n\n" + combinedRules;
  gemini.rules = memoryInstruction + "\n\n" + combinedRules;
  crush.rules = memoryInstruction + "\n\n" + combinedRules;
  copilot.rules = memoryInstruction + "\n\n" + combinedRules;

  # Memory instruction (for tools that support separate memory)
  memory = memoryInstruction;
}
