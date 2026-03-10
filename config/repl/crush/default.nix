{
  pkgs,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  imports = [
    ./common.nix
    ./lsp.nix
    ./mcp.nix
    ./permissions.nix
  ];

  programs.crush = {
    enable = false;
    package = customPkgs.crush;
  };
}
