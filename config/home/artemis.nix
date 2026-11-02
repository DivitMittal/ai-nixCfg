{
  pkgs,
  config,
  ...
}: let
  artemisHome = "${config.xdg.dataHome}/artemis";

  # google/artemis (https://github.com/google/artemis) has no published package
  # to fetch ephemerally: a non-editable build requires a prebuilt Angular
  # "showcase_ui" bundle that isn't checked into the repo, so `uvx --from
  # git+...` (the pattern used for serena/mcp-nixos) fails. Upstream's own
  # install path is a local git checkout driven by `uv run`, which performs an
  # editable install instead and sidesteps that build step entirely.
  ensureArtemisRepo = ''
    if [ ! -d "${artemisHome}/.git" ]; then
      echo "artemis: cloning google/artemis into ${artemisHome}" >&2
      ${pkgs.git}/bin/git clone --depth 1 https://github.com/google/artemis.git "${artemisHome}"
    fi
    cd "${artemisHome}"
  '';

  artemisCli = pkgs.writeShellScriptBin "artemis" ''
    set -euo pipefail
    ${ensureArtemisRepo}
    exec ${pkgs.uv}/bin/uv run artemis "$@"
  '';

  # Direct MCP stdio entrypoint, mirroring upstream's manual IDE config
  # (`python -m mcp_server`, README "MCP Setup" section) rather than going
  # through the `artemis` CLI.
  artemisMcpServer = pkgs.writeShellScriptBin "artemis-mcp-server" ''
    set -euo pipefail
    ${ensureArtemisRepo}
    exec ${pkgs.uv}/bin/uv run python -m mcp_server "$@"
  '';
in {
  # ADB and scrcpy are assumed to be provisioned elsewhere; artemis only needs
  # a device already reachable over `adb` (including TCP/IP over Ethernet).
  home.packages = [
    artemisCli
    artemisMcpServer
    pkgs.ffmpeg
  ];

  home.sessionVariables.ARTEMIS_HOME = artemisHome;

  programs.mcp.servers.artemis = {
    type = "stdio";
    command = "${artemisMcpServer}/bin/artemis-mcp-server";
    args = [];
    env = {
      PYTHONUNBUFFERED = "1";
    };
  };
}
