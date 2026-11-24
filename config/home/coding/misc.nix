{
  config,
  lib,
  pkgs,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  isX86Darwin = pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin";
in {
  ## Keep Grok CLI state (auth.json, bin/) under XDG. jcode's grok-build
  ## provider reads and refreshes $GROK_HOME/auth.json too.
  home.sessionVariables.GROK_HOME = "${config.xdg.configHome}/grok";

  home.packages = lib.attrsets.attrValues ({
      ## Qwen Code
      #qwen-code = customLib.mkPnpmDlxBin pkgs "qwen" "@qwen-code/qwen-code@latest";
      ## KiloCode
      #kilocode-cli = customLib.mkPnpmDlxBin pkgs "kilo" "--package=@kilocode/cli kilocode";
      ## happy-coder — mobile/web client for Codex & Claude Code (binaries:
      ## happy, happy-mcp). Available directly in nixpkgs-26.05-darwin (the
      ## pin already used for x86_64-darwin).
      happy-coder =
        if isX86Darwin
        then pkgs.happy-coder
        else customPkgs.happy-coder;
      ## zoetrope — live Claude Code session graph (binary: zoe).
      inherit (customPkgs) zoetrope;
      ## Archived: only claude, codex, pi-rust and jcode are in active use.
      ## zai — CLI for Z.AI GLM models
      # inherit (customPkgs) zai;
      ## zehn — al3rez/zehn fuzzy-find prompts across claude, codex, pi & opencode histories and resume sessions
      inherit (customPkgs) zehn;
      ## ax — yusukebe/ax AI-agent HTTP/context tool ("AI-era curl", binary:
      ## ax). llm-agents.nix has no x86_64-darwin packages; ax isn't
      ## published to npm (package.json is private), so run it via bun x
      ## straight from its git source there instead.
      ax =
        if isX86Darwin
        then customLib.mkBunxBin pkgs "ax" "github:yusukebe/ax"
        else customPkgs.ax;
      ## goose-cli — Block's open-source coding agent (binary: goose).
      ## Available directly in nixpkgs-26.05-darwin.
      ## Archived.
      # goose-cli =
      #   if isX86Darwin
      #   then pkgs.goose-cli
      #   else customPkgs.goose-cli;
      ## jcode — resource-efficient terminal coding agent (binary: jcode)
      inherit (customPkgs) jcode;
      ## Official Grok Build (binary: grok). The pinned llm-agents package
      ## omits Intel macOS; upstream's npm distribution supports it.
      grok =
        if isX86Darwin
        then customLib.mkBunxBin pkgs "grok" "@xai-official/grok@1.0.89"
        else customPkgs.grok;
      ## mmx-cli — MiniMax CLI (binary: mmx)
      ## Archived.
      # mmx-cli = customLib.mkBunxBin pkgs "mmx" "mmx-cli";
      ## The local Darwin package fills the Intel gap in llm-agents.
      inherit (customPkgs) cursor-agent;
    }
    ## terminal-use — flipbit03/terminal-use headless PTY for agents (binary:
    ## tu). Rust; no x86_64-darwin build, no npm/pypi fallback, and no
    ## Homebrew formula either (checked formulae.brew.sh directly — not just
    ## asserted) — no fallback tier applies.
    // lib.optionalAttrs (!isX86Darwin) {inherit (customPkgs) terminal-use;}
    ## pi-agent-rust — Dicklesworthstone's Rust port of Pi (binary: pi-rust).
    ## Prebuilt only for aarch64-darwin/x86_64-linux, source build on
    ## x86_64-darwin; no aarch64-linux release, and the package's prebuilt
    ## branch reads `source.version` unconditionally, so gate it here.
    // lib.optionalAttrs (lib.elem pkgs.stdenvNoCC.hostPlatform.system [
      "aarch64-darwin"
      "x86_64-linux"
      "x86_64-darwin"
    ]) {inherit (customPkgs) pi-agent-rust;});
}
