{
  lib,
  pkgs,
  ai-nixCfg,
  ...
}: {
  home.packages = lib.attrsets.attrValues {
    inherit (ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system}) lumen;
  };
}
