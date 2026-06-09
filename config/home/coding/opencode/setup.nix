{
  customLib,
  pkgs,
  ...
}: {
  programs.opencode = let
    package = customLib.mkPnpmDlxBin pkgs "opencode" "opencode-ai";
  in {
    enable = true;
    inherit package;
  };
}
