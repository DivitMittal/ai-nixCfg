{pkgs, ...}: let
  pnpmCommand = "${pkgs.pnpm}/bin/pnpm";
in {
  programs.opencode.enableMcpIntegration = false;
  programs.opencode.settings.mcp = {
    octocode = {
      type = "local";
      command = [pnpmCommand "dlx" "octocode-mcp@latest"];
    };
  };
}
