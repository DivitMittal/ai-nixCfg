{
  lib,
  pkgs,
  config,
  customLib,
  ...
}: {
  home.sessionVariables = {
    KAGGLE_CONFIG_DIR = "${config.xdg.configHome}/kaggle";
    HF_HUB_DISABLE_TELEMETRY = "1";
  };
  home.packages = lib.attrsets.attrValues {
    inherit
      (pkgs)
      kaggle
      ;
    hf = customLib.mkUvxBin pkgs "hf" "--from huggingface-hub[cli] hf";
  };
}
