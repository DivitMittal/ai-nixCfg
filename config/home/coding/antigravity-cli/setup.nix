{
  lib,
  pkgs,
  ai-nixCfg,
  ...
}: {
  # The executable is immutable in the Nix store. Updates come from Nix.
  home.sessionVariables.AGY_CLI_DISABLE_AUTO_UPDATE = "true";

  programs.antigravity-cli = {
    enable = true;
    package =
      lib.mkIf (pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin")
      ai-nixCfg.packages.x86_64-darwin.antigravity-cli;
  };
}
