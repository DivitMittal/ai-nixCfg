{
  pkgs,
  customLib,
  ...
}: {
  programs.gemini-cli = let
    package = customLib.mkPnpmDlxBin pkgs "gemini" "@google/gemini-cli";
    # package = pkgs.gemini-cli;
  in {
    enable = false;
    inherit package;
    defaultModel = "gemini-3.1-pro-preview";
  };
}
