{
  lib,
  stdenvNoCC,
  sources,
}: let
  system = stdenvNoCC.hostPlatform.system;
  source = sources.${"zerostack-${system}"} or null;
in
  lib.throwIfNot (source != null) "zerostack: unsupported system ${system}"
  stdenvNoCC.mkDerivation (_finalAttrs: {
    pname = "zerostack";
    version = lib.removePrefix "v" source.version;
    inherit (source) src;

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 zerostack $out/bin/zerostack
      runHook postInstall
    '';

    meta = with lib; {
      description = "Minimal, memory-efficient coding agent written in Rust";
      homepage = "https://github.com/gi-dellav/zerostack";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [DivitMittal];
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      mainProgram = "zerostack";
      sourceProvenance = [sourceTypes.binaryNativeCode];
    };
  })
