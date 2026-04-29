{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "pi" ''
      exec ${pkgs.pnpm}/bin/pnpm dlx @mariozechner/pi-coding-agent "$@"
    '')
  ];
}
