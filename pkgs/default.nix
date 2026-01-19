{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    customPkgs = import ./custom {inherit pkgs;};
    llmAgentsPkgs = inputs.llm-agents.packages.${system};
  in {
    packages = customPkgs // llmAgentsPkgs;
  };
}
