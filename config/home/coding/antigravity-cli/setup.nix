{
  pkgs,
  ai-nixCfg,
  ...
}: {
  programs.antigravity-cli = {
    enable = true;
    package = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system}.antigravity-cli;
  };
}
