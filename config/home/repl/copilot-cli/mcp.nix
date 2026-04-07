{pkgs, ...}: let
  pnpmCommand = "${pkgs.pnpm}/bin/pnpm";
in {
  # Integrate global MCP servers from programs.mcp.servers (when programs.mcp.enable = true)
  programs.github-copilot-cli.enableMcpIntegration = true;

  # Copilot-CLI-specific MCP servers (take precedence over programs.mcp.servers)
  programs.github-copilot-cli.mcpServers = {
    sequential-thinking = {
      type = "local";
      command = pnpmCommand;
      args = ["dlx" "@modelcontextprotocol/server-sequential-thinking"];
    };
    deepwiki = {
      type = "http";
      url = "https://mcp.deepwiki.com/mcp";
    };
    exa = {
      type = "local";
      command = pnpmCommand;
      args = ["dlx" "exa-mcp-server"];
    };
  };
}
