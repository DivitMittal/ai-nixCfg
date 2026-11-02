{
  lib,
  pkgs,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  isX86Darwin = pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin";
in {
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
      ## zai — CLI for Z.AI GLM models
      inherit (customPkgs) zai;
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
      goose-cli =
        if isX86Darwin
        then pkgs.goose-cli
        else customPkgs.goose-cli;
      ## jcode — resource-efficient terminal coding agent (binary: jcode)
      inherit (customPkgs) jcode;
      ## pi-agent-rust — Dicklesworthstone's Rust port of Pi (binary: pi-rust)
      inherit (customPkgs) pi-agent-rust;
      ## zerostack — minimal Rust coding agent, here for temporary testing
      inherit (customPkgs) zerostack;
      ## cursor-agent — Cursor CLI coding agent (binary: cursor-agent)
      inherit (customPkgs) cursor-agent;
      ## mmx-cli — MiniMax CLI (binary: mmx)
      mmx-cli = customLib.mkBunxBin pkgs "mmx" "mmx-cli";
    }
    ## terminal-use — flipbit03/terminal-use headless PTY for agents (binary:
    ## tu). Rust; no x86_64-darwin build, no npm/pypi fallback, and no
    ## Homebrew formula either (checked formulae.brew.sh directly — not just
    ## asserted) — no fallback tier applies.
    // lib.optionalAttrs (!isX86Darwin) {inherit (customPkgs) terminal-use;});

  ## Nix owns jcode; its self-updater would otherwise repopulate ~/.jcode/builds
  ## and ~/.local/bin/jcode, which shadow the profile on PATH.
  home.sessionVariables.JCODE_NO_AUTO_UPDATE = "1";
}
