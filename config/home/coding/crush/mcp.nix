{
  pkgs,
  customLib,
  ...
}: let
  bunxCommand = name: pkg: "${customLib.mkBunxBin pkgs name pkg}/bin/${name}";
in {
  programs.crush.settings.mcp = {
    sequential-thinking = {
      type = "stdio";
      command = bunxCommand "sequential-thinking" "@modelcontextprotocol/server-sequential-thinking";
      args = [];
    };
    deepwiki = {
      type = "http";
      url = "https://mcp.deepwiki.com/mcp";
    };
    octocode = {
      type = "stdio";
      command = bunxCommand "octocode-mcp" "octocode-mcp@latest";
      args = [];
    };
    exa = {
      type = "stdio";
      command = bunxCommand "exa-mcp-server" "exa-mcp-server";
      args = [];
    };
  };
}
