{
  lib,
  pkgs,
  ...
}: {
  home.packages = lib.attrsets.attrValues {
    inherit
      (pkgs)
      geminicommit
      ;
    # aicommit2 = ai-nixCfg.inputs.aicommit2.packages.${hostPlatform.system}.default;
  };
}
