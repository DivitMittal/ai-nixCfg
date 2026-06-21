{
  lib,
  pkgs,
  ai-nixCfg,
  ...
}: let
  inherit (pkgs.stdenvNoCC.hostPlatform) system;
  aicommit2Packages = ai-nixCfg.inputs.aicommit2.packages.${system} or {};
in {
  home.packages = lib.attrsets.attrValues ({
      inherit
        (pkgs)
        geminicommit
        ;
    }
    // lib.optionalAttrs (aicommit2Packages ? default) {
      aicommit2 = aicommit2Packages.default;
    });
}
