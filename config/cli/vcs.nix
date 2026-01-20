{
  lib,
  pkgs,
  ai-nixCfg,
  ...
}: {
  home.packages = lib.attrsets.attrValues {
    inherit
      (pkgs)
      geminicommit
      ;
    # aicommit2 = ai-nixCfg.inputs.aicommit2.packages.${pkgs.stdenvNoCC.hostPlatform.system}.default;
    inherit (ai-nixCfg.inputs.lumen.packages.${pkgs.stdenvNoCC.hostPlatform.system}) lumen;
  };
}
