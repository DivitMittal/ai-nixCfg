{
  lib,
  pkgs,
  ...
}: {
  home.packages = [
    (
      if pkgs ? mcpc && lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.mcpc
      then pkgs.mcpc
      # The 26.05 Intel macOS pin lacks mcpc. Bun honors the npm CLI's
      # Node shebang, so the fallback supplies Node even in a clean profile.
      else
        (pkgs.writeShellScriptBin "mcpc" ''
          export PATH="${lib.makeBinPath [pkgs.nodejs_24]}''${PATH:+:$PATH}"
          exec ${lib.getExe pkgs.bun} x --package @apify/mcpc@0.8.0 mcpc "$@"
        '')
    )
  ];
}
