{
  lib,
  pkgs,
  ai-nixCfg,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  home.packages = lib.attrsets.attrValues {
    ## ck — local-first semantic + hybrid BM25 grep/search (for AI & humans)
    inherit (customPkgs) ck;
    ## codegraph — semantic code intelligence for AI coding agents
    inherit (customPkgs) codegraph;
    ## dolt — relational database with Git-style branching/merging
    inherit (customPkgs) dolt;
  };
}
