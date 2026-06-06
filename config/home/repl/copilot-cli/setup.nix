{pkgs, ...}: {
  programs.github-copilot-cli = {
    enable = false;
    # Wrap the CLI to auto-enable GitHub MCP tools and show the banner.
    package = pkgs.writeShellScriptBin "copilot" ''
      exec ${pkgs.github-copilot-cli}/bin/copilot --enable-all-github-mcp-tools --banner "$@"
    '';
  };
}
