{self, ...}: {
  flake.homeManagerConfigurations = rec {
    Cfg = import ./setup.nix self;
    ## Alias for Cfg
    default = Cfg;
  };
}
