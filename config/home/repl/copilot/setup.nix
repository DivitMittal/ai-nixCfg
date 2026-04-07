{
  pkgs,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  programs.github-copilot = let
    package = pkgs.writeShellScriptBin "copilot" ''
      exec ${customPkgs.copilot-cli}/bin/copilot --enable-all-github-mcp-tools --banner "$@"
    '';
  in {
    enable = false;
    inherit package;
  };
}
