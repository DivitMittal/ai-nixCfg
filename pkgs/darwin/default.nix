{pkgs}:
{
  Perplexity-bin = pkgs.callPackage ./Perplexity-bin/package.nix {};
}
// pkgs.lib.optionalAttrs (pkgs.stdenvNoCC.hostPlatform.system == "x86_64-darwin") {
  cursor-agent = pkgs.callPackage ./cursor-agent/package.nix {};
}
