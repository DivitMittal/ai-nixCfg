{
  pkgs,
  lib,
  options,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  programs.claude-code =
    {
      enable = true;
      # llm-agents.nix (customPkgs' source) doesn't build claude-code for
      # x86_64-darwin; fall back to nixpkgs' own package there.
      package = customPkgs.claude-code or pkgs.claude-code;
    }
    # Like codex's mutableUserSettings: merge declared keys into writable
    # settings.json / plugins/known_marketplaces.json at activation, so
    # /plugin, /config and marketplaces added at runtime keep working.
    # Consumers pinning an older home-manager (e.g. infra-nixCfg) lack the
    # option, so only set it where it exists.
    // lib.optionalAttrs (options.programs.claude-code ? mutableSettings) {
      mutableSettings = true;
    };
}
