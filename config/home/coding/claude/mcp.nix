{
  pkgs,
  customLib,
  ...
}: let
  pnpmDlxCommand = name: pkg: "${customLib.mkPnpmDlxBin pkgs name pkg}/bin/${name}";
in {
  programs.claude-code.settings = {
    enableAllProjectMcpServers = true;
  };
  ## Passed to the `claude` cli & not added as a global configuration
  programs.claude-code.mcpServers = {
    deepwiki = {
      type = "http";
      url = "https://mcp.deepwiki.com/mcp";
    };
    octocode = {
      type = "stdio";
      command = pnpmDlxCommand "octocode-mcp" "octocode-mcp@latest";
      args = [];
    };
  };
}
