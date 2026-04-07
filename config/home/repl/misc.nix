{
  lib,
  pkgs,
  ...
}: {
  home.packages = lib.attrsets.attrValues {
    ## Qwen Code
    qwen-code = pkgs.writeShellScriptBin "qwen" ''
      exec ${pkgs.pnpm}/bin/pnpm dlx @qwen-code/qwen-code@latest "$@"
    '';
    ## KiloCode
    kilocode-cli = pkgs.writeShellScriptBin "kilo" ''
      exec ${pkgs.pnpm}/bin/pnpm --package=@kilocode/cli dlx kilocode "$@"
    '';
  };
}
