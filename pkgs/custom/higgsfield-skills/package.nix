{
  lib,
  runCommand,
  writeText,
  sources,
}: let
  source = sources.higgsfield-skills;

  # Official hosted MCP server (OAuth on first connect), as shipped by
  # higgsfield-ai/cursor-plugin. Bundling it into the Claude plugin means it
  # only loads where the plugin is enabled, instead of in every session.
  mcpJson = writeText "higgsfield-mcp.json" (builtins.toJSON {
    mcpServers.higgsfield = {
      type = "http";
      url = "https://mcp.higgsfield.ai/mcp";
    };
  });
in
  # The repo is itself a Claude Code marketplace (`higgsfield`) with one plugin
  # rooted at `./`, so dropping `.mcp.json` at the root attaches it to that plugin.
  runCommand "higgsfield-skills-${source.date}" {
    passthru = {inherit (source) version;};
    meta = {
      description = "Higgsfield AI agent skills as a Claude Code marketplace, bundled with the Higgsfield MCP server";
      homepage = "https://github.com/higgsfield-ai/skills";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  } ''
    cp -r ${source.src} $out
    chmod -R u+w $out
    install -m644 ${mcpJson} $out/.mcp.json
  ''
