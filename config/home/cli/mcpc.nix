{
  pkgs,
  customLib,
  ...
}: {
  ## mcpc: universal MCP client CLI (tools/resources/prompts, persistent
  ## sessions, OAuth via OS keychain, `--json` for agent code mode). npm-only
  ## with a native keyring addon, so it runs through bun x rather than a Nix
  ## build. Published only under the `@apify` scope.
  home.packages = [
    (customLib.mkBunxBin pkgs "mcpc" "@apify/mcpc")
  ];
}
