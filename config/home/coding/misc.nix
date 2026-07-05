{
  lib,
  pkgs,
  ai-nixCfg,
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
  };
}
