{pkgs, ...}: {
  imports = [
    ./commands.nix
    ./mcp.nix
    ./rules.nix
    ./settings.nix
  ];

  programs.gemini-cli = {
    enable = true;
    package = pkgs.writeShellScriptBin "gemini" ''
      exec ${pkgs.pnpm}/bin/pnpm dlx @google/gemini-cli "$@"
    '';
    # package = pkgs.gemini-cli;
    defaultModel = "gemini-3-pro-preview";
  };
}
