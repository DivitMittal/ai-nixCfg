{
  pkgs,
  lib,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  programs.kestra.enable = true;

  home.packages = lib.attrsets.attrValues {
    # llm-agents.nix (customPkgs' source) doesn't publish packages for
    # x86_64-darwin at all; fall back to running apm-cli (PyPI) via uv.
    apm =
      if pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin"
      then customLib.mkUvxBin pkgs "apm" "--from apm-cli apm"
      else customPkgs.apm;
  };
}
