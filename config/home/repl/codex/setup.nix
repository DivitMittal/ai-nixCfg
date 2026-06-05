{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) optionalAttrs optionalString;
in {
  programs.codex = let
    package =
      (pkgs.writeShellScriptBin "codex" ''
        ${optionalString config.home.preferXdgDirectories ''export CODEX_HOME="${config.xdg.configHome}/codex"''}
        exec ${pkgs.pnpm}/bin/pnpm dlx @openai/codex "$@"
      '')
      // (optionalAttrs config.home.preferXdgDirectories {version = "0.94.0";});
  in {
    enable = true;
    inherit package;
  };
}
