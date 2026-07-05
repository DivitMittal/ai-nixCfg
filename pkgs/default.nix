{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    customPkgs = import ./custom {inherit pkgs;};
    darwinPkgs = pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin (import ./darwin {inherit pkgs;});
    # Filter to only derivations — llm-agents.nix (via blueprint) may expose
    # uncalled callPackage functions for some packages (e.g. apm).
    llmAgentsPkgs = pkgs.lib.filterAttrs (_: pkgs.lib.isDerivation) (inputs.llm-agents.packages.${system} or {});
    steipetePkgs = inputs.nix-steipete-tools.packages.${system} or {};
  in {
    packages = customPkgs // darwinPkgs // llmAgentsPkgs // steipetePkgs;
  };
}
