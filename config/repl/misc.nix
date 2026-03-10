{
  lib,
  pkgs,
  ...
}: {
  home.packages = lib.attrsets.attrValues {
    ## Qwen Code
    # qwen-code = pkgs.writeShellScriptBin "qwen-code" ''
    #   exec ${pkgs.pnpm}/bin/pnpm dlx @qwen-code/qwen-code@latest "$@"
    # '';
    ## KiloCode
    kilocode-cli = pkgs.writeShellScriptBin "kilo-code" ''
      exec ${pkgs.pnpm}/bin/pnpm --package=@kilocode/cli dlx kilocode "$@"
    '';
  };
}
