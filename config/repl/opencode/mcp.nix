{pkgs, ...}: let
  pnpmCommand = "${pkgs.pnpm}/bin/pnpm";
in {
  programs.opencode.settings.mcp = {
    octocode = {
      type = "local";
      command = [pnpmCommand "dlx" "octocode-mcp@latest"];
    };
  };
}
