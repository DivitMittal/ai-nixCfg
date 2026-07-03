{
  lib,
  pkgs,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  pnpmDlxCommand = name: pkg: "${customLib.mkPnpmDlxBin pkgs name pkg}/bin/${name}";
  uvxCommand = name: args: "${customLib.mkUvxBin pkgs name args}/bin/${name}";
in {
  home.packages = lib.attrsets.attrValues {
    ## WhatsApp MCP Server
    inherit (customPkgs) gowa;
  };

  programs.mcp = {
    enable = true;
    servers = {
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
      sequential-thinking = {
        type = "stdio";
        command = pnpmDlxCommand "sequential-thinking" "@modelcontextprotocol/server-sequential-thinking";
        args = [];
      };
      # Headroom: exposes headroom_compress / headroom_retrieve / headroom_stats.
      # Requires the headroom proxy to be running (hr-proxy alias starts it).
      headroom = {
        type = "stdio";
        command = uvxCommand "headroom" "--from headroom-ai[all] headroom";
        args = ["mcp" "serve"];
        env = {
          HEADROOM_PROXY_URL = "http://127.0.0.1:8787";
        };
      };
      # Cognee: persistent cross-session knowledge graph memory (remember / recall / forget).
      cognee = {
        type = "stdio";
        command = uvxCommand "cognee-mcp" "--from cognee-mcp cognee-mcp";
        args = [];
      };
      ### Capabilities already enabled in modern coding environments
      # filesystem = {
      #   command = pnpmDlxCommand "filesystem" "@modelcontextprotocol/server-filesystem";
      #   args = [];
      # };
      ## beads
      # memory = {
      #   command = pnpmDlxCommand "memory" "@modelcontextprotocol/server-memory";
      #   args = [];
      # };
      ## Capabilities that require domain-specific setup to save context
      # markitdown = {
      #   command = "${uvxCommand "markitdown-mcp" "markitdown-mcp"}/bin/markitdown-mcp";
      #   args = [];
      # };
    };
  };
}
