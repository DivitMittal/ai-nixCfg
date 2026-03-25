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
    ./common.nix
    ./mcp.nix
    ./settings.nix
  ];

  home.packages = mkIf config.programs.codex.enable (lib.attrsets.attrValues {
    inherit (customPkgs) ccusage-codex;
  });

  # package = customPkgs.codex;
  # home.sessionVariables.CODEX_HOME = "${config.xdg.configHome}/codex";
  programs.codex = let
    package = pkgs.writeShellScriptBin "codex" ''
      export CODEX_HOME="${config.xdg.configHome}/codex"
      exec ${pkgs.pnpm}/bin/pnpm dlx @openai/codex "$@"
    '';
  in {
    enable = true;
    inherit package;
  };
}
