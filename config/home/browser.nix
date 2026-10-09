{
  pkgs,
  ai-nixCfg,
  customLib,
  lib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  pnpmDlxCommand = name: pkg: "${customLib.mkPnpmDlxBin pkgs name pkg}/bin/${name}";
in {
  home.packages = lib.attrsets.attrValues {
    inherit (customPkgs) lightpanda;
    agent-browser =
      if pkgs.stdenv.isDarwin
      then customLib.mkPnpmDlxBin pkgs "agent-browser" "agent-browser"
      else customPkgs.agent-browser;
  };

  # Lightpanda sends usage telemetry by default; opt out.
  home.sessionVariables.LIGHTPANDA_DISABLE_TELEMETRY = "false";

  programs.mcp.servers.playwright = {
    type = "stdio";
    command = pnpmDlxCommand "playwright-mcp" "@playwright/mcp";
    args = [];
  };
}
