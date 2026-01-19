{
  inputs,
  lib,
  ...
}: {
  flake.overlays = {
    default = inputs.llm-agents.overlays.default;
    llm-agents = inputs.llm-agents.overlays.default;
    custom = final: prev: {
      custom = import ../pkgs/custom {pkgs = final;};
    };
  };
}
