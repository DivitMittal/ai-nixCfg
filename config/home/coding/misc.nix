{
  lib,
  pkgs,
  customLib,
  ...
}: {
  home.packages = lib.attrsets.attrValues {
    ## Qwen Code
    #qwen-code = customLib.mkPnpmDlxBin pkgs "qwen" "@qwen-code/qwen-code@latest";
    ## KiloCode
    #kilocode-cli = customLib.mkPnpmDlxBin pkgs "kilo" "--package=@kilocode/cli kilocode";
  };
}
