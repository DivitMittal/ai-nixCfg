{
  lib,
  stdenvNoCC,
  sources,
}: let
  system = stdenvNoCC.hostPlatform.system;
  source = sources.${"lumen-${system}"} or null;
in
  lib.throwIfNot (source != null) "lumen: unsupported system ${system}"
  stdenvNoCC.mkDerivation (_finalAttrs: {
    pname = "lumen";
    version = lib.removePrefix "v" source.version;
    inherit (source) src;

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 lumen $out/bin/lumen
      runHook postInstall
    '';

    meta = {
      description = "AI-powered commit message and PR description generator";
      homepage = "https://github.com/jnsahaj/lumen";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [DivitMittal];
      platforms = ["x86_64-darwin"];
      mainProgram = "lumen";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  })
