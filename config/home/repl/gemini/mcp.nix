{pkgs, ...}: let
  pnpmCommand = "${pkgs.pnpm}/bin/pnpm";
  # uvCommand = "${pkgs.uv}/bin/uvx";
in {
  # Integrate global MCP servers from programs.mcp.servers (when programs.mcp.enable = true)
  programs.gemini-cli.enableMcpIntegration = true;

  # Gemini-specific MCP servers (take precedence over programs.mcp.servers)
  programs.gemini-cli.settings.mcpServers = {
    sequential-thinking = {
      command = pnpmCommand;
      args = ["dlx" "@modelcontextprotocol/server-sequential-thinking"];
    };
    deepwiki = {
      trust = true;
      httpUrl = "https://mcp.deepwiki.com/mcp";
    };
    octocode = {
      command = pnpmCommand;
      args = ["dlx" "octocode-mcp@latest"];
    };
  };
}
