{
  lib,
  pkgs,
  ai-nixCfg,
  ...
}: {
  home.packages = lib.attrsets.attrValues {
    inherit (ai-nixCfg.inputs.lumen.packages.${pkgs.stdenvNoCC.hostPlatform.system}) lumen;
    inherit (ai-nixCfg.inputs.llm-agents.packages.${pkgs.stdenvNoCC.hostPlatform.system}) hunk tuicr;
  };
}
