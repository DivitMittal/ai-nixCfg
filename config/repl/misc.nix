{lib, ...}: {
  home.packages = lib.attrsets.attrValues {
    ## Qwen Code
    # qwen-code = customPkgs.qwen-code;
    # qwen-code = pkgs.writeShellScriptBin "qwen-code" ''
    #   exec ${pkgs.pnpm}/bin/pnpm dlx @qwen-code/qwen-code@latest "$@"
    # '';
  };
}
