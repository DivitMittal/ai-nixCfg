{
  lib,
  buildNpmPackage,
  makeWrapper,
  nodejs_latest,
  sources,
}: let
  source = sources.spotify-mcp-server;
  libexec = "$out/lib/node_modules/spotify-mcp-server";

  ## Upstream reads and rewrites spotify-config.json (client credentials plus
  ## refreshed tokens) beside build/, which is read-only in the store. postPatch
  ## makes the path overridable; the wrappers point it at a private state dir.
  stateFlags = lib.escapeShellArgs [
    "--run"
    ''state="''${XDG_STATE_HOME:-$HOME/.local/state}/spotify-mcp-server"; mkdir -p -m 700 "$state"''
    "--run"
    ''export SPOTIFY_CONFIG_FILE="''${SPOTIFY_CONFIG_FILE:-$state/spotify-config.json}"''
  ];
in
  buildNpmPackage {
    pname = "spotify-mcp-server";
    version = "1.0.0-unstable-${source.date}";
    inherit (source) src;

    ## engines asks for Node >= 26.8.1, but nothing in src/ needs more than
    ## stable Node APIs, and this nixpkgs tops out at Node 25.
    nodejs = nodejs_latest;
    npmDepsHash = "sha256-E3SEQSZvrcYQcyWG9GS1N1I1EdMNiPPBFtNMKs/6PoE=";

    postPatch = ''
      substituteInPlace src/utils.ts \
        --replace-fail "const CONFIG_FILE = path.join(__dirname, '../spotify-config.json');" \
                       "const CONFIG_FILE = process.env.SPOTIFY_CONFIG_FILE ?? path.join(__dirname, '../spotify-config.json');"
    '';

    nativeBuildInputs = [makeWrapper];

    postInstall = ''
      rm -f $out/bin/spotify-mcp
      makeWrapper ${lib.getExe nodejs_latest} $out/bin/spotify-mcp \
        --add-flags ${libexec}/build/index.js ${stateFlags}
      ## One-time OAuth flow; needs clientId/clientSecret/redirectUri in the
      ## config file first (see spotify-config.example.json upstream).
      makeWrapper ${lib.getExe nodejs_latest} $out/bin/spotify-mcp-auth \
        --add-flags ${libexec}/build/auth.js ${stateFlags}
    '';

    meta = {
      description = "MCP server for controlling Spotify playback, search and playlists";
      homepage = "https://github.com/marcelmarais/spotify-mcp-server";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [DivitMittal];
      platforms = lib.platforms.unix;
      mainProgram = "spotify-mcp";
    };
  }
