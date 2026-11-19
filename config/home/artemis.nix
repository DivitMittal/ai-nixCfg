{
  pkgs,
  config,
  lib,
  ...
}: let
  artemisHome = "${config.xdg.dataHome}/artemis";

  # cryptography no longer ships Intel macOS wheels; provide its native build
  # dependencies instead of relying on a host Homebrew/Rust installation.
  nativeBuildEnvironment = lib.optionalString (pkgs.stdenv.hostPlatform.system == "x86_64-darwin") ''
    export PATH="${lib.makeBinPath [pkgs.cargo pkgs.rustc pkgs.clang pkgs.pkg-config]}:$PATH"
    export OPENSSL_LIB_DIR="${lib.getLib pkgs.openssl}/lib"
    export OPENSSL_INCLUDE_DIR="${lib.getDev pkgs.openssl}/include"
  '';

  # google/artemis (https://github.com/google/artemis) has no published package
  # to fetch ephemerally: a non-editable build requires a prebuilt Angular
  # "showcase_ui" bundle that isn't checked into the repo, so `uvx --from
  # git+...` (the pattern used for serena/mcp-nixos) fails. Upstream's own
  # install path is a local git checkout driven by `uv run`, which performs an
  # editable install instead and sidesteps that build step entirely.
  ensureArtemisRepo = ''
    ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg config.xdg.dataHome}
    if [ ! -d "${artemisHome}/.git" ]; then
      echo "artemis: cloning google/artemis into ${artemisHome}" >&2
      ${pkgs.git}/bin/git clone --depth 1 https://github.com/google/artemis.git "${artemisHome}"
    fi
    cd "${artemisHome}"
  '';

  artemisCli = pkgs.writeShellScriptBin "artemis" ''
    set -euo pipefail
    ${ensureArtemisRepo}
    ${nativeBuildEnvironment}
    exec ${pkgs.uv}/bin/uv run --python 3.12 --no-dev artemis "$@"
  '';

  # Direct MCP stdio entrypoint, mirroring upstream's manual IDE config
  # (`python -m mcp_server`, README "MCP Setup" section) rather than going
  # through the `artemis` CLI.
  artemisMcpServer = pkgs.writeShellScriptBin "artemis-mcp-server" ''
    set -euo pipefail
    ${ensureArtemisRepo}
    ${nativeBuildEnvironment}
    exec ${pkgs.uv}/bin/uv run --python 3.12 --no-dev python -m mcp_server "$@"
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
