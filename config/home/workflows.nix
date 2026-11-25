{
  config,
  pkgs,
  lib,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  programs.n8n = {
    enable = true;
    # Avoid the nixpkgs pnpm build. Bun installs the published CLI, which runs
    # on Node and uses native SQLite.
    package = pkgs.writeShellScriptBin "n8n" ''
      export PATH="${pkgs.nodejs_24}/bin:$PATH"
      exec ${pkgs.bun}/bin/bun x n8n@2.49.5 "$@"
    '';
    environment = {
      DB_TYPE = "sqlite";
      DB_SQLITE_DATABASE = "${config.xdg.stateHome}/n8n/.n8n/database.sqlite";
      N8N_DIAGNOSTICS_ENABLED = false;
      N8N_VERSION_NOTIFICATIONS_ENABLED = false;
    };
  };

  home.packages = lib.attrsets.attrValues {
    # llm-agents.nix (customPkgs' source) doesn't publish packages for
    # x86_64-darwin at all; fall back to running apm-cli (PyPI) via uv.
    apm =
      if pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin"
      then customLib.mkUvxBin pkgs "apm" "--from apm-cli apm"
      else customPkgs.apm;
  };
}
