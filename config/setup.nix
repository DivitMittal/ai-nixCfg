self: let
  ## Eagerly resolve config files at flake-parts level (shallow call stack) to avoid
  ## hitting Nix's max-call-depth when lib.filesystem.listFilesRecursive is called
  ## deep inside the home-manager module system evaluation.
  configFiles =
    (
      self.inputs."import-tree"
        .withLib self.inputs.nixpkgs.lib
        .matchNot "setup\\.nix|.*(default|lib)\\.nix"
        .pipeTo (x: x)
    )
    ./.;
in
{
  imports =
    configFiles
    ++ [
      self.homeManagerModules.default
      self.inputs.nix-openclaw.homeManagerModules.openclaw
    ];

  _module.args = {
    ai-nixCfg = self;
  };
}
