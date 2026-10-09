{
  pkgs,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  programs.crush = {
    enable = false;
    # llm-agents.nix has no x86_64-darwin packages; crush (charmbracelet/crush)
    # is available directly in nixpkgs-26.05-darwin (the pin already used for
    # x86_64-darwin), unlike the rest of llm-agents.nix's packages.
    package =
      if pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin"
      then pkgs.crush
      else customPkgs.crush;
  };
}
