{
  pkgs,
  customLib,
  ...
}: let
  pnpmDlxCommand = name: pkg: "${customLib.mkPnpmDlxBin pkgs name pkg}/bin/${name}";
in {
  # Integrate global MCP servers from programs.mcp.servers (when programs.mcp.enable = true)
  programs.gemini-cli.enableMcpIntegration = true;

  # Gemini-specific MCP servers (take precedence over programs.mcp.servers)
  programs.gemini-cli.settings.mcpServers = {
    sequential-thinking = {
      command = pnpmDlxCommand "sequential-thinking" "@modelcontextprotocol/server-sequential-thinking";
      args = [];
    };
    deepwiki = {
      trust = true;
      httpUrl = "https://mcp.deepwiki.com/mcp";
    };
    octocode = {
      command = pnpmDlxCommand "octocode-mcp" "octocode-mcp@latest";
      args = [];
    };
  };
}
