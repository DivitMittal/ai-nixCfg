{
  pkgs,
  customLib,
  ...
}: let
  pnpmDlxCommand = name: pkg: "${customLib.mkPnpmDlxBin pkgs name pkg}/bin/${name}";
in {
  # Integrate global MCP servers from programs.mcp.servers (when programs.mcp.enable = true)
  programs.github-copilot-cli.enableMcpIntegration = true;

  # Copilot-CLI-specific MCP servers (take precedence over programs.mcp.servers)
  programs.github-copilot-cli.mcpServers = {
    sequential-thinking = {
      type = "local";
      command = pnpmDlxCommand "sequential-thinking" "@modelcontextprotocol/server-sequential-thinking";
      args = [];
    };
    deepwiki = {
      type = "http";
      url = "https://mcp.deepwiki.com/mcp";
    };
    exa = {
      type = "local";
      command = pnpmDlxCommand "exa-mcp-server" "exa-mcp-server";
      args = [];
    };
  };
}
