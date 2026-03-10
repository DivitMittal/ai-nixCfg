{pkgs, ...}: {
  imports = [
    ./commands.nix
    ./mcp.nix
    ./rules.nix
    ./settings.nix
  ];

  programs.gemini-cli = let
    package = pkgs.writeShellScriptBin "gemini" ''
      exec ${pkgs.pnpm}/bin/pnpm dlx @google/gemini-cli "$@"
    '';
    # package = pkgs.gemini-cli;
  in {
    enable = true; # Currently using for web-search capabilities in CCS
    inherit package;
    defaultModel = "gemini-3-pro-preview";
  };
}
