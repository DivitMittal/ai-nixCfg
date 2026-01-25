{
  pkgs,
  lib,
  config,
  ai-nixCfg,
  ...
}: let
  inherit (lib) mkIf;
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  imports = [
    ./commands.nix
    ./mcp.nix
    ./rules.nix
    ./settings.nix
    ./skills.nix
  ];

  home.packages = mkIf config.programs.codex.enable (lib.attrsets.attrValues {
    inherit (customPkgs) ccusage-codex;
  });

  programs.codex = {
    enable = false;
    package = customPkgs.codex;
  };
}
