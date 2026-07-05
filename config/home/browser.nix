{
  pkgs,
  lib,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  pnpmDlxCommand = name: pkg: "${customLib.mkPnpmDlxBin pkgs name pkg}/bin/${name}";
in {
  home.packages = lib.attrsets.attrValues (
    {
      ## Lightpanda — headless browser for AI agents & automation (prebuilt nightly)
      inherit (customPkgs) lightpanda;
    }
    ## agent-browser — headless browser automation CLI for AI agents.
    ## Excluded on Darwin where its dashboard fetchPnpmDeps OOMs (see
    ## pkgs/default.nix); installs only on Linux where it builds from source.
    // (lib.optionalAttrs (customPkgs ? agent-browser) {
      inherit (customPkgs) agent-browser;
    })
  );

  # Lightpanda sends usage telemetry by default; opt out.
  home.sessionVariables.LIGHTPANDA_DISABLE_TELEMETRY = "false";

  programs.mcp.servers.playwright = {
    type = "stdio";
    command = pnpmDlxCommand "playwright-mcp" "@playwright/mcp";
    args = [];
  };
}
