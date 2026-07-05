{
  lib,
  pkgs,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  home.packages = lib.attrsets.attrValues {
    ## Qwen Code
    #qwen-code = customLib.mkPnpmDlxBin pkgs "qwen" "@qwen-code/qwen-code@latest";
    ## KiloCode
    #kilocode-cli = customLib.mkPnpmDlxBin pkgs "kilo" "--package=@kilocode/cli kilocode";
    ## happy-coder — mobile/web client for Codex & Claude Code (binaries: happy, happy-mcp)
    inherit (customPkgs) happy-coder;
    ## zai — CLI for Z.AI GLM models
    inherit (customPkgs) zai;
    ## mmx-cli — MiniMax CLI (binary: mmx)
    mmx-cli = customLib.mkPnpmDlxBin pkgs "mmx" "mmx-cli";
  };
}
