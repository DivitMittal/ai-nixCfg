{
  pkgs,
  lib,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  home.packages = lib.attrsets.attrValues {
    ## Lightpanda — headless browser for AI agents & automation (prebuilt nightly)
    inherit (customPkgs) lightpanda;
  };
  # Lightpanda sends usage telemetry by default; opt out.
  home.sessionVariables.LIGHTPANDA_DISABLE_TELEMETRY = "true";
}
