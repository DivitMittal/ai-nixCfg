{
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  glibc,
  sources,
}: let
  source = sources.${"wacli-${stdenvNoCC.hostPlatform.system}"} or null;
in
  lib.throwIfNot (source != null) "wacli: unsupported system ${stdenvNoCC.hostPlatform.system}"
  stdenvNoCC.mkDerivation {
    pname = "wacli";
    inherit (source) version src;

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = lib.optional stdenvNoCC.hostPlatform.isLinux autoPatchelfHook;
    buildInputs = lib.optional stdenvNoCC.hostPlatform.isLinux glibc;

    installPhase = ''
      runHook preInstall
      install -Dm755 wacli $out/bin/wacli
      runHook postInstall
    '';

    meta = with lib; {
      description = "WhatsApp CLI built on whatsmeow, with local sync and full-text search";
      homepage = "https://github.com/openclaw/wacli";
      license = licenses.mit;
      maintainers = with maintainers; [DivitMittal];
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      mainProgram = "wacli";
      sourceProvenance = [sourceTypes.binaryNativeCode];
    };
  }
