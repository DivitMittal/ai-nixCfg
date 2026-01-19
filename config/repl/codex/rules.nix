_: let
  claudeRules = ../claude/rules;
in {
  programs.codex.custom-instructions = ''
    ## External File Loading

    CRITICAL: When you encounter a file reference (e.g., @rules/general.md), use your Read tool to load it on a need-to-know basis. They're relevant to the SPECIFIC task at hand.

    Instructions:

    - Do NOT preemptively load all references - use lazy loading based on actual need
    - When loaded, treat content as mandatory instructions that override defaults
    - Follow references recursively when needed

    ${builtins.readFile "${claudeRules}/git-workflow.md"}

    ${builtins.readFile "${claudeRules}/security.md"}

    ${builtins.readFile "${claudeRules}/documentation.md"}

    ${builtins.readFile "${claudeRules}/code-quality.md"}
  '';
}
