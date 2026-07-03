{
  pkgs,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  ## rtk — Rust Token Killer: CLI proxy that compresses command output to cut
  ## LLM token use 60-90% (binary: rtk). Packaged via the llm-agents flake.
  ## Wired in as headroom's context tool (HEADROOM_CONTEXT_TOOL = "rtk" in
  ## optimization/headroom.nix); run `rtk init -g` per agent to install the
  ## auto-rewrite hook.
  home.packages = [customPkgs.rtk];
}
