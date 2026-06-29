{
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  glibc,
  gcc-unwrapped,
  sources,
}: let
  # nvfetcher tracks one entry per platform binary; select by current system.
  # To bump the nightly pin, run `pkgs-update` from the devshell.
  source = sources.${"lightpanda-${stdenvNoCC.hostPlatform.system}"} or null;
in
  lib.throwIfNot (source != null) "lightpanda: unsupported system ${stdenvNoCC.hostPlatform.system}"
  stdenvNoCC.mkDerivation (_finalAttrs: {
    inherit (source) pname version src;

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = lib.optional stdenvNoCC.hostPlatform.isLinux autoPatchelfHook;
    buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
      glibc
      gcc-unwrapped.lib
    ];

    installPhase = ''
      runHook preInstall
      install -Dm555 $src $out/bin/lightpanda
      runHook postInstall
    '';

    meta = with lib; {
      description = "Headless browser built from scratch for AI agents and automation";
      homepage = "https://github.com/lightpanda-io/browser";
      license = licenses.agpl3Only;
      maintainers = with maintainers; [DivitMittal];
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      mainProgram = "lightpanda";
      sourceProvenance = [sourceTypes.binaryNativeCode];
    };
  })
