{pkgs, ...}: {
  programs.opencode = let
    package = pkgs.writeShellScriptBin "opencode" ''
      exec ${pkgs.pnpm}/bin/pnpm dlx opencode-ai "$@"
    '';
  in {
    enable = true;
    inherit package;
  };
}
