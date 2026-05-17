{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.devshell.flakeModule];

  perSystem = {
    pkgs,
    config,
    ...
  }: {
    devshells.default = {
      devshell = rec {
        name = "ai-nixCfg";
        motd = "{202}Welcome to {91}${name} {202}devshell!{reset} \n $(menu)";
        startup = {
          git-hooks.text = ''
            ${config.pre-commit.installationScript}
          '';
        };
        packages = lib.attrsets.attrValues {
          inherit
            (pkgs)
            ### LSPs & Formatters
            ## Nix
            nixd
            alejandra
            ## Package management
            nvfetcher
            ;
        };
      };
      commands = [
        {
          name = "pkgs-update";
          help = "Update package sources via nvfetcher";
          command = "nvfetcher -c $PRJ_ROOT/pkgs/nvfetcher.toml -o $PRJ_ROOT/pkgs/_sources";
        }
      ];
    };
  };
}
