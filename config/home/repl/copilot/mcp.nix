{
  pkgs,
  customLib,
  ...
}: let
  pnpmDlxCommand = name: pkg: "${customLib.mkPnpmDlxBin pkgs name pkg}/bin/${name}";
in {
  programs.github-copilot.mcpServers = {
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
