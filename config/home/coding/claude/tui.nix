{
  lib,
  ai-nixCfg,
  config,
  pkgs,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  inherit (lib) mkIf;
  # llm-agents.nix has no x86_64-darwin packages; ccstatusline is
  # npm-published, so run it via bun x there instead.
  ccstatuslinePkg =
    if pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin"
    then customLib.mkBunxBin pkgs "ccstatusline" "ccstatusline"
    else customPkgs.ccstatusline;
in {
  ## Status Line package
  home.packages = mkIf config.programs.claude-code.enable [ccstatuslinePkg];

  programs.claude-code.settings = {
    theme = "dark";
    rendererMode = "fullscreen";
    statusLine = {
      command = "${ccstatuslinePkg}/bin/ccstatusline";
      padding = 0;
      type = "command";
    };
  };
}
