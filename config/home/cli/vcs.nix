{pkgs, ...}: let
  aicommit2 = pkgs.writeShellScriptBin "aicommit2" ''
    export PATH="${pkgs.nodejs_24}/bin:$PATH"
    exec ${pkgs.bun}/bin/bun x aicommit2@2.16.0 "$@"
  '';
  aic2 = pkgs.writeShellScriptBin "aic2" ''exec ${aicommit2}/bin/aicommit2 "$@"'';
in {
  home.packages = [pkgs.geminicommit aicommit2 aic2];
}
