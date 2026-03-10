{
  pkgs,
  lib,
  ...
}: {
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
    # zeroclaw = pkgs.writeShellScriptBin "zeroclaw" ''
    #   exec ${pkgs.pnpm}/bin/pnpm dlx zeroclaw "$@"
    # '';
  };
}
