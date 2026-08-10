{
  pkgs,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  programs.claude-code = {
    enable = true;
    # llm-agents.nix (customPkgs' source) doesn't build claude-code for
    # x86_64-darwin; fall back to nixpkgs' own package there.
    package = customPkgs.claude-code or pkgs.claude-code;
  };
}
