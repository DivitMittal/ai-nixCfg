{lib, ...}: let
  ## Import domain modules
  commonLib = import ./lib.nix {inherit lib;};
  commands = import ./commands {inherit lib;};
  skills = import ./skills {inherit lib;};
  agents = import ./agents {inherit lib;};
  rules = import ./rules {inherit lib;};
in {
  ## Export metadata for reference
  inherit (commands) commandMeta;
  inherit (skills) skillMeta;
  inherit (agents) agentMeta;

  ## Export generators
  inherit (commands) mkClaudeCommand mkCodexPrompt mkCopilotCommand mkGeminiCommand mkOpenCodeCommand;
  inherit (skills) mkClaudeSkill mkCodexSkill mkOpenCodeSkill;
  inherit (agents) mkClaudeAgent mkCopilotAgent mkOpenCodeAgent;

  ## Pre-generated sets per tool (compose from domain modules)
  claude = {
    inherit (commands.claude) commands;
    inherit (skills.claude) skills;
    inherit (agents.claude) agents;
    inherit (rules.claude) rules;
  };

  codex = {
    inherit (commands.codex) prompts;
    inherit (skills.codex) skills;
    inherit (rules.codex) rules;
  };

  copilot = {
    inherit (commands.copilot) commands;
    inherit (agents.copilot) agents;
    inherit (rules.copilot) rules;
  };

  gemini = {
    inherit (commands.gemini) commands;
    inherit (rules.gemini) rules;
  };

  opencode = {
    inherit (commands.opencode) commands;
    inherit (skills.opencode) skills;
    inherit (agents.opencode) agents;
    inherit (rules.opencode) rules;
  };

  crush = {
    inherit (commands.crush) commands;
    inherit (rules.crush) rules;
  };

  ## Memory instruction (for tools that support separate memory)
  memory = commonLib.memoryInstruction;
}
