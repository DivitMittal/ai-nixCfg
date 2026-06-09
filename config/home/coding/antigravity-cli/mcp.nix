{
  pkgs,
  customLib,
  ...
}: let
  pnpmDlxCommand = name: pkg: "${customLib.mkPnpmDlxBin pkgs name pkg}/bin/${name}";
in {
  # Integrate global MCP servers from programs.mcp.servers (when programs.mcp.enable = true)
  programs.antigravity-cli.enableMcpIntegration = true;

  # Antigravity-specific MCP servers (written to ~/.gemini/config/mcp_config.json)
  programs.antigravity-cli.mcpServers = {
    sequential-thinking = {
      command = pnpmDlxCommand "sequential-thinking" "@modelcontextprotocol/server-sequential-thinking";
      args = [];
    };
    deepwiki = {
      serverUrl = "https://mcp.deepwiki.com/mcp";
    };
    octocode = {
      command = pnpmDlxCommand "octocode-mcp" "octocode-mcp@latest";
      args = [];
    };
  };
}
