{
  inputs,
  lib,
  self,
  ...
}: {
  perSystem = {system, ...}: let
    ## The config sets unfree packages (e.g. n8n), so the standalone app needs an
    ## allowUnfree pkgs — flake-parts' default perSystem pkgs has neither config
    ## nor overlays.
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    inherit (pkgs.stdenvNoCC) hostPlatform;

    ## Identity is derived from the invoking user's environment so the app is
    ## user-agnostic: run with `--impure` and it adapts to whoever runs it; in
    ## pure evaluation it falls back to generic placeholders. These values don't
    ## affect the package set — they only satisfy home-manager assertions.
    envOr = name: default: let
      value = builtins.getEnv name;
    in
      if value == ""
      then default
      else value;
    username = envOr "USER" "user";
    homeDir = envOr "HOME" (
      if hostPlatform.isDarwin
      then "/Users/${username}"
      else "/home/${username}"
    );

    ## homeManagerConfigurations.default is a raw module (not evaluated),
    ## so accessing it here carries no withSystem cycle risk.
    cfg = inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs lib;
      extraSpecialArgs = {inherit inputs;};
      modules = [
        {
          home.username = username;
          home.homeDirectory = homeDir;
          home.stateVersion = "25.05";
          ## Some configs (e.g. aichat) read $EDITOR from sessionVariables, which
          ## the consuming host normally provides. Supply a default for the
          ## standalone app so package enumeration doesn't fault on a missing key.
          home.sessionVariables.EDITOR = lib.mkDefault "vim";
          ## Keep the ephemeral AI shell lean and free of the brew-nix overlay:
          ## drop the darwin GUI app casks from config/home/gui.nix.
          aiNixCfg.guiApps.enable = false;
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
