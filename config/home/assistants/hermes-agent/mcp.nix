{
  config,
  lib,
  ...
}: let
  hermesMcpNames = [
    "deepwiki"
    "octocode"
    "exa"
  ];

  selectedServers = lib.filterAttrs (name: _server: builtins.elem name hermesMcpNames) config.programs.mcp.servers;

  toHermesServer = _name: server:
    lib.removeAttrs server [
      "type"
      "disabled"
    ]
    // {
      enabled = !(server.disabled or false);
    };
in {
  programs.hermes-agent = lib.mkIf (config.programs.hermes-agent.enable && config.programs.mcp.enable) {
    mcpServers = lib.mapAttrs toHermesServer selectedServers;
  };
}
