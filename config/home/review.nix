{
  lib,
  pkgs,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  home.packages = lib.attrsets.attrValues {
    # ai-nixCfg.inputs.lumen (jnsahaj/lumen's own flake) instantiates
    # unstable nixpkgs internally, which now hard-throws for x86_64-darwin;
    # fetch the upstream release binary directly there instead (see
    # pkgs/custom/lumen).
    lumen =
      if pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin"
      then customPkgs.lumen
      else ai-nixCfg.inputs.lumen.packages.${pkgs.stdenvNoCC.hostPlatform.system}.lumen;
  };
}
