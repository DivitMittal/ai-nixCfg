{
  lib,
  pkgs,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
  isX86Darwin = pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin";
in {
  home.packages = lib.attrsets.attrValues ({
      ## codegraph — semantic code intelligence for AI coding agents.
      ## llm-agents.nix has no x86_64-darwin packages; codegraph is
      ## npm-published under a scoped name, so use that there instead.
      codegraph =
        if isX86Darwin
        then customLib.mkPnpmDlxBin pkgs "codegraph" "@colbymchenry/codegraph"
        else customPkgs.codegraph;
      ## dolt — relational database with Git-style branching/merging.
      ## Available directly in nixpkgs-26.05-darwin (the pin already used for
      ## x86_64-darwin), unlike the rest of llm-agents.nix's packages.
      dolt =
        if isX86Darwin
        then pkgs.dolt
        else customPkgs.dolt;
    }
    ## ck — local-first semantic + hybrid BM25 grep/search (for AI & humans).
    ## Rust + onnxruntime; no x86_64-darwin build from llm-agents.nix and no
    ## npm/pypi/brew fallback exists.
    // lib.optionalAttrs (!isX86Darwin) {inherit (customPkgs) ck;});
}
