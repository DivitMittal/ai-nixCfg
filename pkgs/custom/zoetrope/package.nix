{
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  glibc,
  gcc-unwrapped,
  sources,
}: let
  # nvfetcher tracks one entry per platform release archive; select by current system.
  source = sources.${"zoetrope-${stdenvNoCC.hostPlatform.system}"} or null;
in
  lib.throwIfNot (source != null) "zoetrope: unsupported system ${stdenvNoCC.hostPlatform.system}"
  stdenvNoCC.mkDerivation (_finalAttrs: {
    inherit (source) pname version src;

    sourceRoot = ".";

    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = lib.optional stdenvNoCC.hostPlatform.isLinux autoPatchelfHook;
    buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
      glibc
      gcc-unwrapped.lib
    ];

    installPhase = ''
      runHook preInstall
      install -Dm755 */zoe "$out/bin/zoe"
      runHook postInstall
    '';

    meta = {
      description = "Watch a Claude Code session as a live flow graph, in your terminal or your browser";
      homepage = "https://github.com/furkankly/zoetrope";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [DivitMittal];
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      mainProgram = "zoe";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  })
