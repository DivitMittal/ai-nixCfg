{
  pkgs,
  customLib,
  ...
}: {
  programs.gemini-cli = let
    package = customLib.mkPnpmDlxBin pkgs "gemini" "@google/gemini-cli";
    # package = pkgs.gemini-cli;
  in {
    enable = true; # Currently using for web-search capabilities in CCS
    inherit package;
    defaultModel = "gemini-3.1-pro-preview";
  };
}
