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
    ## Ralph Wiggum
    ralph-tui = customLib.mkPnpmDlxBin pkgs "ralph-tui" "ralph-tui";
    ## GNHF
    inherit (customPkgs) gnhf;
  };
}
