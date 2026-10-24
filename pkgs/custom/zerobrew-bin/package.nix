{
  lib,
  stdenvNoCC,
  sources,
}: let
  system = stdenvNoCC.hostPlatform.system;
  zbSourceKey =
    {
      aarch64-darwin = "zerobrew-zb-aarch64";
      x86_64-darwin = "zerobrew-zb-x86_64";
    }.${
      system
    } or null;
  zbxSourceKey =
    {
      aarch64-darwin = "zerobrew-zbx-aarch64";
      x86_64-darwin = "zerobrew-zbx-x86_64";
    }.${
      system
    } or null;
  zb = sources.${zbSourceKey} or null;
  zbx = sources.${zbxSourceKey} or null;
in
  lib.throwIfNot (zb != null && zbx != null) "zerobrew-bin: unsupported system ${system}"
  stdenvNoCC.mkDerivation {
    pname = "zerobrew-bin";
    inherit (zb) version;
    dontUnpack = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      install -m755 ${zb.src} $out/bin/zb
      install -m755 ${zbx.src} $out/bin/zbx
      runHook postInstall
    '';

    meta = {
      description = "A 5-20x faster experimental Homebrew alternative (used here as the zbx ephemeral-formula-run tier in the x86_64-darwin package fallback cascade)";
      homepage = "https://github.com/lucasgelfond/zerobrew";
      license = lib.licenses.bsd3;
      maintainers = with lib.maintainers; [DivitMittal];
      platforms = ["aarch64-darwin" "x86_64-darwin"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      mainProgram = "zb";
    };
  }
