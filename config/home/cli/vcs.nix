{
  lib,
  pkgs,
  customLib,
  ...
}: {
  home.packages = lib.attrsets.attrValues {
    inherit
      (pkgs)
      geminicommit
      ;
    aicommit2 = customLib.mkBunxBin pkgs "aicommit2" "aicommit2";
  };
}
