{
  pkgs,
  lib,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  home.packages = lib.attrsets.attrValues {
    ## Spec Kit
    # spec-kit = customPkgs.spec-kit;
    ## OpenSpec CLI
    openspec = customLib.mkUvxBin pkgs "openspec" "@fission-ai/openspec@latest";
    # openspec = customPkgs.openspec;
    ## OpenSpec UI
    inherit (customPkgs) openspecui;
  };
}
