{
  pkgs,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  imports = [
    ./commands.nix
    ./lsp.nix
    ./mcp.nix
    ./permissions.nix
    ./rules.nix
  ];

  programs.crush = {
    enable = true;
    package = customPkgs.crush;
  };
}
