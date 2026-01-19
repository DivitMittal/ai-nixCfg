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
    ./agents.nix
    ./commands.nix
    ./hooks.nix
    ./mcp.nix
    ./output-styles
    ./permissions.nix
    ./plugins.nix
    ./rules.nix
    ./settings.nix
    ./skills.nix
  ];

  home.packages = mkIf config.programs.claude-code.enable (lib.attrsets.attrValues {
    inherit (customPkgs) ccusage;
    claude-code-switcher = pkgs.writeShellScriptBin "ccs" ''
      exec ${pkgs.pnpm}/bin/pnpm dlx @kaitranntt/ccs "$@"
    '';
  });

  programs.claude-code = {
    enable = true;
    package = customPkgs.claude-code;
  };
}
