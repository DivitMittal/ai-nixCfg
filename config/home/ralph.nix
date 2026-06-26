{
  pkgs,
  lib,
  customLib,
  ...
}: {
  home.packages = lib.attrValues {
    ralph-tui = customLib.mkPnpmDlxBin pkgs "ralph-tui" "ralph-tui";
    zeroshot = customLib.mkPnpmDlxBin pkgs "zeroshot" "@the-open-engine/zeroshot";
    gnhf = customLib.mkPnpmDlxBin pkgs "gnhf" "gnhf";
  };
}
