{
  pkgs,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  programs.claude-code = {
    enable = true;
    package = customPkgs.claude-code;
  };
}
