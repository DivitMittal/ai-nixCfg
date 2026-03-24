{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "n8n" ''
      #!${pkgs.stdenvNoCC.shell}
      exec ${pkgs.pnpm}/bin/pnpm dlx n8n "$@"
    '')
  ];
}
