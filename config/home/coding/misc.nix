{
  config,
  lib,
  pkgs,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  isX86Darwin = pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin";
  archivedTools =
    {
      inherit (customPkgs) zai zoetrope zehn cursor-agent;
      happy-coder =
        if isX86Darwin
        then pkgs.happy-coder
        else customPkgs.happy-coder;
      goose-cli =
        if isX86Darwin
        then pkgs.goose-cli
        else customPkgs.goose-cli;
      grok =
        if isX86Darwin
        then customLib.mkBunxBin pkgs "grok" "@xai-official/grok@1.0.89"
        else customPkgs.grok;
      ax =
        if isX86Darwin
        then customLib.mkBunxBin pkgs "ax" "github:yusukebe/ax"
        else customPkgs.ax;
      ## mmx-cli — MiniMax CLI (binary: mmx)
      mmx-cli = customLib.mkBunxBin pkgs "mmx" "mmx-cli";
      lazycodex = customLib.mkBunxBin pkgs "lazycodex" "lazycodex-ai";
    }
    // lib.optionalAttrs (!isX86Darwin) {inherit (customPkgs) terminal-use;};
in {
  options.aiCoding.installArchivedTools = lib.mkEnableOption "the optional archived coding CLI collection";

  config = {
    ## Keep Grok CLI state (auth.json, bin/) under XDG. jcode's grok-build
    ## provider reads and refreshes $GROK_HOME/auth.json too.
    home.sessionVariables.GROK_HOME = "${config.xdg.configHome}/grok";

    home.packages =
      [customPkgs.jcode]
      ## pi-agent-rust — Dicklesworthstone's Rust port of Pi (binary: pi-rust).
      ## Prebuilt only for aarch64-darwin/x86_64-linux, source build on
      ## x86_64-darwin; no aarch64-linux release, and the package's prebuilt
      ## branch reads `source.version` unconditionally, so gate it here.
      ++ lib.optional (lib.elem pkgs.stdenvNoCC.hostPlatform.system [
        "aarch64-darwin"
        "x86_64-linux"
        "x86_64-darwin"
      ])
      customPkgs.pi-agent-rust
      ++ lib.optionals config.aiCoding.installArchivedTools (lib.attrValues archivedTools);
  };
}
