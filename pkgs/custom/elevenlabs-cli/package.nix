{
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  makeWrapper,
  glibc,
  gcc-unwrapped,
  sources,
}: let
  # nvfetcher tracks one entry per platform release archive; select by current system.
  source = sources.${"elevenlabs-cli-${stdenvNoCC.hostPlatform.system}"} or null;
in
  lib.throwIfNot (source != null) "elevenlabs-cli: unsupported system ${stdenvNoCC.hostPlatform.system}"
  stdenvNoCC.mkDerivation (_finalAttrs: {
    pname = "elevenlabs-cli";
    inherit (source) version src;

    # Archives unpack to elevenlabs-cli-<target>/elevenlabs.
    sourceRoot = ".";

    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs =
      [makeWrapper]
      ++ lib.optional stdenvNoCC.hostPlatform.isLinux autoPatchelfHook;
    buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
      glibc
      gcc-unwrapped.lib
    ];

    # The store copy can't self-update. Telemetry is opt-out upstream
    # (`--telemetry` / ELEVENLABS_TELEMETRY / DO_NOT_TRACK); default it off.
    installPhase = ''
      runHook preInstall
      install -Dm755 */elevenlabs "$out/libexec/elevenlabs/elevenlabs"
      makeWrapper "$out/libexec/elevenlabs/elevenlabs" "$out/bin/elevenlabs" \
        --set-default ELEVENLABS_TELEMETRY off
      runHook postInstall
    '';

    meta = {
      description = "ElevenLabs CLI: agents, speech, music, dubbing and the rest of the API";
      homepage = "https://github.com/elevenlabs/cli";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [DivitMittal];
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      mainProgram = "elevenlabs";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  })
