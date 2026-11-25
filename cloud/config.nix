{
  lib,
  pkgs,
}: let
  coding = ../config/home/coding;
  claude = (import (coding + "/claude/common.nix") {inherit lib;}).programs.claude-code;
  codex = (import (coding + "/codex/common.nix") {inherit lib;}).programs.codex;
  inherit (import (coding + "/_common/commands") {inherit lib;}) commandMeta;
  # Project slash commands require a string for argument-hint, including bracketed hints.
  claudeCommands = lib.mapAttrs (name: content: let
    hint = commandMeta.${name}.argument-hint or null;
  in
    if hint == null
    then content
    else lib.replaceStrings ["argument-hint: ${hint}\n"] ["argument-hint: ${builtins.toJSON hint}\n"] content)
  claude.commands;
  deny = ((import (coding + "/claude/permissions.nix") {}).programs.claude-code.settings.permissions).deny;
  deepwiki = import (coding + "/_common/deepwiki.nix");
  json = pkgs.formats.json {};
  file = name: text: {
    inherit name;
    path = pkgs.writeText (builtins.baseNameOf name) text;
  };
  textFiles = prefix: suffix: lib.mapAttrsToList (name: file "${prefix}${name}${suffix}");
  shellInstructions = ''
    In a prepared cloud worker, load the toolchain in Bash with
    `source "$HOME/.local/state/ai-nixcfg-cloud/env"`.
  '';
  portableSkills = builtins.removeAttrs codex.skills ["herdr"];
  settings = json.generate "claude-settings.json" {
    permissions = {inherit deny;};
    hooks.SessionStart = [
      {
        hooks = [
          {
            type = "command";
            command = ''bash "$CLAUDE_PROJECT_DIR/.claude/ai-nixcfg-session.sh"'';
            timeout = 10;
          }
        ];
      }
    ];
  };
in
  pkgs.linkFarm "cloud-agent-config" (
    [
      (file "codex/AGENTS.md" (codex.context + "\n\n" + shellInstructions))
      (file "claude/.claude/rules/ai-nixcfg.md" (codex.context + "\n\n" + shellInstructions))
      {
        name = "claude/.claude/settings.json";
        path = settings;
      }
      {
        name = "claude/.claude/ai-nixcfg-session.sh";
        path = ./claude-session.sh;
      }
      (file "cursor/.cursor/rules/ai-nixcfg.mdc" ''
        ---
        alwaysApply: true
        ---
        ${codex.context}

        ${shellInstructions}
      '')
      {
        name = "optional/claude/.mcp.json";
        path = json.generate "claude-mcp.json" {mcpServers = {inherit deepwiki;};};
      }
      {
        name = "optional/cursor/deepwiki.json";
        path = json.generate "cursor-deepwiki.json" {inherit (deepwiki) url;};
      }
    ]
    ++ textFiles "codex/.agents/skills/" "/SKILL.md" portableSkills
    ++ textFiles "cursor/.cursor/skills/" "/SKILL.md" portableSkills
    ++ textFiles "claude/.claude/skills/" "/SKILL.md" (builtins.removeAttrs claude.skills ["herdr"])
    ++ textFiles "claude/.claude/agents/" ".md" claude.agents
    ++ textFiles "claude/.claude/commands/" ".md" claudeCommands
  )
