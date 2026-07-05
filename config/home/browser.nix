{
  pkgs,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  pnpmDlxCommand = name: pkg: "${customLib.mkPnpmDlxBin pkgs name pkg}/bin/${name}";
in {
  home.packages = [
    customPkgs.lightpanda

    ## agent-browser — headless browser automation CLI for AI agents.
    ## On Linux, install the upstream Nix-built derivation. On Darwin, where
    ## its dashboard fetchPnpmDeps OOMs, wrap the upstream npm package via
    ## `pnpm dlx` instead — same upstream package, no source build required.
    (
      if pkgs.stdenv.isDarwin
      then customLib.mkPnpmDlxBin pkgs "agent-browser" "agent-browser"
      else customPkgs.agent-browser
    )
  ];

  # Lightpanda sends usage telemetry by default; opt out.
  home.sessionVariables.LIGHTPANDA_DISABLE_TELEMETRY = "false";

  programs.mcp.servers.playwright = {
    type = "stdio";
    command = pnpmDlxCommand "playwright-mcp" "@playwright/mcp";
    args = [];
  };
}
