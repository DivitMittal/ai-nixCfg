{
  lib,
  pkgs,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  pnpmDlxCommand = name: pkg: "${customLib.mkPnpmDlxBin pkgs name pkg}/bin/${name}";
in {
  home.packages = lib.attrsets.attrValues {
    ## WhatsApp MCP Server
    inherit (customPkgs) gowa;
  };

  programs.mcp = {
    enable = false;
    servers = {
      deepwiki = {
        url = "https://mcp.deepwiki.com/mcp";
      };
      octocode = {
        command = pnpmDlxCommand "octocode-mcp" "octocode-mcp@latest";
        args = [];
      };
      exa = {
        command = pnpmDlxCommand "exa-mcp-server" "exa-mcp-server";
        args = [];
      };
      ### Capabilities already enabled in modern coding environments
      # filesystem = {
      #   command = pnpmDlxCommand "filesystem" "@modelcontextprotocol/server-filesystem";
      #   args = [];
      # };
      ## ultrathink
      # sequential-thinking = {
      #   command = pnpmDlxCommand "sequential-thinking" "@modelcontextprotocol/server-sequential-thinking";
      #   args = [];
      # };
      ## beads
      # memory = {
      #   command = pnpmDlxCommand "memory" "@modelcontextprotocol/server-memory";
      #   args = [];
      # };
      ## Capabilities that require domain-specific setup to save context
      # playwright = {
      #   command = pnpmDlxCommand "playwright-mcp" "@playwright/mcp";
      #   args = [];
      # };
      # markitdown = {
      #   command = "${customLib.mkUvxBin pkgs "markitdown-mcp" "markitdown-mcp"}/bin/markitdown-mcp";
      #   args = [];
      # };
    };
  };
}
