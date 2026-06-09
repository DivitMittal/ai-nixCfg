{
  pkgs,
  customLib,
  ...
}: let
  pnpmDlxCommand = name: pkg: "${customLib.mkPnpmDlxBin pkgs name pkg}/bin/${name}";
in {
  programs.crush.settings.mcp = {
    sequential-thinking = {
      type = "stdio";
      command = pnpmDlxCommand "sequential-thinking" "@modelcontextprotocol/server-sequential-thinking";
      args = [];
    };
    deepwiki = {
      type = "http";
      url = "https://mcp.deepwiki.com/mcp";
    };
    octocode = {
      type = "stdio";
      command = pnpmDlxCommand "octocode-mcp" "octocode-mcp@latest";
      args = [];
    };
    exa = {
      type = "stdio";
      command = pnpmDlxCommand "exa-mcp-server" "exa-mcp-server";
      args = [];
    };
  };
}
