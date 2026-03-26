{
  pkgs,
  lib,
  config,
  ai-nixCfg,
  ...
}: let
  inherit (lib) mkIf optionalString;
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  imports = [
    ./common.nix
    ./mcp.nix
    ./settings.nix
  ];

  home.packages = mkIf config.programs.codex.enable (lib.attrsets.attrValues {
    inherit (customPkgs) ccusage-codex;
  });

  # package = customPkgs.codex;
  programs.codex = let
    package =
      (pkgs.writeShellScriptBin "codex" ''
        ${optionalString config.home.preferXdgDirectories ''export CODEX_HOME="${config.xdg.configHome}/codex"''}
        exec ${pkgs.pnpm}/bin/pnpm dlx @openai/codex "$@"
      '')
      // {version = "0.94.0";};
  in {
    enable = true;
    inherit package;
  };
}
