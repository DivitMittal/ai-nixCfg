{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    customPkgs = import ./custom {inherit pkgs;};
    llmAgentsPkgs = inputs.llm-agents.packages.${system} or {};
    steipetePkgs = inputs.nix-steipete-tools.packages.${system} or {};
  in {
    packages = customPkgs // llmAgentsPkgs // steipetePkgs;
  };
}
