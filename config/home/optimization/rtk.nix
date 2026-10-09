{
  pkgs,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  isX86Darwin = pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin";
in {
  ## rtk — Rust Token Killer: CLI proxy that compresses command output to cut
  ## LLM token use 60-90% (binary: rtk). Packaged via the llm-agents flake;
  ## also available directly in nixpkgs-26.05-darwin (the pin already used
  ## for x86_64-darwin), unlike the rest of llm-agents.nix's packages.
  ## Wired in as headroom's context tool (HEADROOM_CONTEXT_TOOL = "rtk" in
  ## optimization/headroom.nix); run `rtk init -g` per agent to install the
  ## auto-rewrite hook.
  ## toon — token-oriented object notation CLI for compact agent data
  ## exchange. Not in nixpkgs; npm-published as `@toon-format/cli` (bin:
  ## toon), so run it via bun x on x86_64-darwin instead.
  home.packages = [
    (
      if isX86Darwin
      then pkgs.rtk
      else customPkgs.rtk
    )
    (
      if isX86Darwin
      then customLib.mkBunxBin pkgs "toon" "@toon-format/cli"
      else customPkgs.toon
    )
  ];
}
