{
  lib,
  buildNpmPackage,
  makeWrapper,
  nodejs,
  sources,
}: let
  source = sources.spotify-library-mcp;
  libexec = "$out/lib/node_modules/spotify-library-mcp";

  ## Upstream keeps its refresh token, budgets and caches beside the code, which
  ## is read-only in the store, so every wrapper redirects them to a state dir.
  stateArgs = [
    "--run"
    ''state="''${XDG_STATE_HOME:-$HOME/.local/state}/spotify-library-mcp"; mkdir -p -m 700 "$state"''
    "--run"
    ''export SPOTIFY_ENV_FILE="$state/.env" SPOTIFY_BUDGET_FILE="$state/.search-budget.json" SPOTIFY_CACHE_DIR="$state/cache" SPOTIFY_SNAPSHOT_DIR="$state/backups"''
  ];
  stateFlags = lib.escapeShellArgs stateArgs;
in
  buildNpmPackage {
    pname = "spotify-library-mcp";
    version = "1.3.0-unstable-${source.date}";
    inherit (source) src;

    npmDepsHash = "sha256-UVZrfePxnrmwgRBPnaVvWz2bbOG09dVL6x8TlDfKS2I=";
    dontNpmBuild = true;

    nativeBuildInputs = [makeWrapper];

    postInstall = ''
      rm -f $out/bin/spot
      makeWrapper ${lib.getExe nodejs} $out/bin/spot \
        --add-flags ${libexec}/bin/spot.js ${stateFlags}
      makeWrapper ${lib.getExe nodejs} $out/bin/spotify-library-mcp \
        --add-flags ${libexec}/src/server.js ${stateFlags}
      makeWrapper ${lib.getExe nodejs} $out/bin/spotify-library-auth \
        --add-flags ${libexec}/scripts/auth.js ${stateFlags}
    '';

    meta = {
      description = "Local MCP server and CLI for curating your own Spotify library";
      homepage = "https://github.com/QuinnFrederick/spotify-library-mcp";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [DivitMittal];
      platforms = lib.platforms.unix;
      mainProgram = "spotify-library-mcp";
    };
  }
