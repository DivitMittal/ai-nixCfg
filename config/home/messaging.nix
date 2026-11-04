{
  lib,
  pkgs,
  ai-nixCfg,
  customLib,
  ...
}: let
  customPkgs = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system};
in {
  ## Messaging tools act on personal accounts and pass other people's messages
  ## to agents, so the MCP servers are launchers on PATH rather than entries in
  ## programs.mcp.servers: register one per tool once you've logged in, e.g.
  ## `claude mcp add telegram -- telegram-mcp`.
  home.packages = lib.attrsets.attrValues {
    inherit (customPkgs) wacli discrawl spotify-library-mcp spotify-mcp-server;

    ## Scriptable chat CLIs for agents; the human TUIs (iamb, weechat) live in
    ## infra-nixCfg's home/comms.
    inherit
      (pkgs)
      matrix-commander-rs # Matrix: one-shot send/listen with JSON output
      ii # IRC: filesystem-based (write to `in`, read `out` per channel)
      ;

    ## Must come from git: `telegram-mcp` on PyPI is an unrelated project, and it
    ## would receive the Telegram session credentials.
    telegram-mcp = customLib.mkUvxBin pkgs "telegram-mcp" "--from git+https://github.com/chigwell/telegram-mcp telegram-mcp";
    telegram-mcp-generate-session = customLib.mkUvxBin pkgs "telegram-mcp-generate-session" "--from git+https://github.com/chigwell/telegram-mcp telegram-mcp-generate-session";

    matrix-mcp = customLib.mkUvxBin pkgs "matrix-mcp" "matrix-mcp";
    linkedin-mcp = customLib.mkUvxBin pkgs "linkedin-mcp" "mcp-server-linkedin@latest";
  };
}
