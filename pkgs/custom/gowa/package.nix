{
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  glibc,
  unzip,
  sources,
}: let
  inherit (stdenvNoCC.hostPlatform) system;
  # nvfetcher tracks one entry per platform archive; select by current system.
  # To bump the release, run `pkgs-update` from the devshell.
  source = sources.${"gowa-${system}"} or null;
  # Each archive names its binary after the upstream platform, not the program.
  binaries = {
    x86_64-linux = "linux-amd64";
    aarch64-linux = "linux-arm64";
    armv7l-linux = "linux-armv7";
    i686-linux = "linux-386";
    x86_64-darwin = "darwin-amd64";
    aarch64-darwin = "darwin-arm64";
  };
  binary = binaries.${system} or null;
in
  lib.throwIfNot (source != null && binary != null) "gowa: unsupported system ${system}"
  stdenvNoCC.mkDerivation (_finalAttrs: {
    pname = "gowa";
    inherit (source) version src;

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [unzip] ++ lib.optional stdenvNoCC.hostPlatform.isLinux autoPatchelfHook;
    buildInputs = lib.optional stdenvNoCC.hostPlatform.isLinux glibc;

    installPhase = ''
      runHook preInstall
      install -Dm755 ${binary} $out/bin/gowa
      runHook postInstall
    '';

    meta = {
      description = "WhatsApp REST API with support for UI, Webhooks, and MCP";
      homepage = "https://github.com/aldinokemal/go-whatsapp-web-multidevice";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [DivitMittal];
      platforms = ["x86_64-linux" "aarch64-linux" "armv7l-linux" "i686-linux" "x86_64-darwin" "aarch64-darwin"];
      mainProgram = "gowa";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  })
