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
    ## zehn — al3rez/zehn fuzzy-find prompts across claude, codex, pi & opencode histories and resume sessions
    inherit (customPkgs) zehn;
    ## ax — yusukebe/ax AI-agent HTTP/context tool ("AI-era curl", binary: ax)
    inherit (customPkgs) ax;
    ## terminal-use — flipbit03/terminal-use headless PTY for agents (binary: tu)
    inherit (customPkgs) terminal-use;
    ## mmx-cli — MiniMax CLI (binary: mmx)
    mmx-cli = customLib.mkPnpmDlxBin pkgs "mmx" "mmx-cli";
  };
}
