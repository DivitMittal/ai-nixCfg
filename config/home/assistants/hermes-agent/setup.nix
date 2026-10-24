{
  pkgs,
  ai-nixCfg,
  lib,
  ...
}: let
  inherit (pkgs.stdenvNoCC.hostPlatform) system;
  llmPkgs = ai-nixCfg.inputs.llm-agents.packages.${system} or {};
  # nix-hermes-agent's build unconditionally pulls in the "nemo-relay" extra
  # (an observability plugin), whose native extension (nemo-relay==0.3 on PyPI)
  # only ships wheels for macosx_arm64/manylinux/win — no x86_64-darwin wheel
  # exists upstream, so the build "succeeds" by grabbing the arm64 wheel and
  # fails at import with "slice is not valid mach-o file". There's no working
  # fallback for hermes-agent on x86_64-darwin at all (llm-agents.nix doesn't
  # publish for that system either), so skip this fallback there too.
  fallbackPkgs =
    if system == "x86_64-darwin"
    then {}
    else ai-nixCfg.inputs.nix-hermes-agent.packages.${system} or {};

  hermesPackage =
    llmPkgs.hermes-agent or fallbackPkgs.hermes-agent or null;
in {
  programs.hermes-agent = lib.mkIf (hermesPackage != null) {
    enable = true;
    package = hermesPackage;
  };
}
