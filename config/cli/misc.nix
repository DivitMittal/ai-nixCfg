{
  pkgs,
  lib,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  home.packages = lib.attrsets.attrValues {
    ### ClawdBot
    ## OpenClaw
    openclaw = pkgs.writeShellScriptBin "openclaw" ''
      exec ${pkgs.pnpm}/bin/pnpm dlx openclaw@latest "$@"
    '';
    ## PicoClaw
    # picoclaw = pkgs.writeShellScriptBin "picoclaw" ''
    #   exec ${pkgs.pnpm}/bin/pnpm dlx picoclaw "$@"
    # '';
    ## ZeroClaw
    inherit(customPkgs) zeroclaw;
  };
}
