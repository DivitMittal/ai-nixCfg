{
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  glibc,
  sources,
}: let
  source = sources.${"discrawl-${stdenvNoCC.hostPlatform.system}"} or null;
in
  lib.throwIfNot (source != null) "discrawl: unsupported system ${stdenvNoCC.hostPlatform.system}"
  stdenvNoCC.mkDerivation {
    pname = "discrawl";
    inherit (source) version src;

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = lib.optional stdenvNoCC.hostPlatform.isLinux autoPatchelfHook;
    buildInputs = lib.optional stdenvNoCC.hostPlatform.isLinux glibc;

    installPhase = ''
      runHook preInstall
      install -Dm755 discrawl $out/bin/discrawl
      runHook postInstall
    '';

    meta = with lib; {
      description = "Discord CLI that archives guild data to local SQLite for offline search";
      homepage = "https://github.com/openclaw/discrawl";
      license = licenses.mit;
      maintainers = with maintainers; [DivitMittal];
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      mainProgram = "discrawl";
      sourceProvenance = [sourceTypes.binaryNativeCode];
    };
  }
