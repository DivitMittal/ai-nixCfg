{
  pkgs,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  bunxCommand = name: pkg: "${customLib.mkBunxBin pkgs name pkg}/bin/${name}";
in {
  home.packages = [
    customPkgs.lightpanda

    ## agent-browser — headless browser automation CLI for AI agents.
    ## Run the upstream npm package via `bun x` on all platforms, which avoids
    ## the Nix source build and its pnpm dependency fetch.
    (customLib.mkBunxBin pkgs "agent-browser" "agent-browser")
  ];

  # Lightpanda sends usage telemetry by default; opt out.
  home.sessionVariables.LIGHTPANDA_DISABLE_TELEMETRY = "true";

  programs.mcp.servers.playwright = {
    type = "stdio";
    command = bunxCommand "playwright-mcp" "@playwright/mcp";
    args = [];
  };
}
