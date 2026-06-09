_: {
  programs.claude-code.settings.permissions = {
    # additionalDirectories = [ "../docs/" ];
    allow = [
      "Read"
      "Bash(git diff:*)"
      "Edit"
      "Write"

      ## MCPs
      ## Serena MCP
      "mcp__serena__*"
      ## Octocode MCP
      "mcp__octocode__*"
    ];
    defaultMode = "acceptEdits";
    deny = [
      "WebFetch"
      "Read(./.env)"
      "Read(./secrets/**)"
    ];
    #disableBypassPermissionsMode = "disable";
  };
}
