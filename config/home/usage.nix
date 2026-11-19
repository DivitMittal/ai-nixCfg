{
  pkgs,
  lib,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  home.packages = lib.attrsets.attrValues {
    # llm-agents.nix doesn't publish packages for x86_64-darwin; ccusage is
    # npm-published, so run it ephemerally via bun x there instead.
    ccusage =
      if pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin"
      then customLib.mkBunxBin pkgs "ccusage" "ccusage"
      else customPkgs.ccusage;
  };
}
