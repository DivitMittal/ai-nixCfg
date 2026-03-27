{
  inputs,
  lib,
  self,
  ...
}: {
  perSystem = {pkgs, ...}: let
    inherit (pkgs.stdenvNoCC) hostPlatform;

    homeDir =
      if hostPlatform.isDarwin
      then "/Users/div"
      else "/home/div";

    ## homeManagerConfigurations.default is a raw module (not evaluated),
    ## so accessing it here carries no withSystem cycle risk.
    cfg = inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs lib;
      extraSpecialArgs = {inherit inputs;};
      modules = [
        {
          home.username = "div";
          home.homeDirectory = homeDir;
          home.stateVersion = "25.05";
        }
        self.homeManagerConfigurations.default
      ];
    };

    env = pkgs.buildEnv {
      name = "ai-env";
      paths = lib.filter (p: p != null) cfg.config.home.packages;
      pathsToLink = ["/bin" "/share"];
      ignoreCollisions = true;
    };
  in {
    apps.ai = {
      type = "app";
      program = toString (pkgs.writeShellScript "ai" ''
        export PATH="${env}/bin:$PATH"
        exec "''${SHELL:-${pkgs.bashInteractive}/bin/bash}"
      '');
    };
  };
}
