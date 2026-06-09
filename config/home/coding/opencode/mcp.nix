{
  pkgs,
  customLib,
  ...
}: let
  pnpmDlxCommand = name: pkg: "${customLib.mkPnpmDlxBin pkgs name pkg}/bin/${name}";
in {
  programs.opencode.enableMcpIntegration = false;
  programs.opencode.settings.mcp = {
    octocode = {
      type = "local";
      command = [(pnpmDlxCommand "octocode-mcp" "octocode-mcp@latest")];
    };
  };
}
