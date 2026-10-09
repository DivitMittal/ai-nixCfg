{
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  glibc,
  gcc-unwrapped,
  sources,
}: let
  system = stdenvNoCC.hostPlatform.system;
  source = sources.${"jcode-${system}"} or null;
  binaryNames = {
    x86_64-linux = "jcode-linux-x86_64";
    aarch64-linux = "jcode-linux-aarch64";
    x86_64-darwin = "jcode-macos-x86_64";
    aarch64-darwin = "jcode-macos-aarch64";
  };
  binaryName = binaryNames.${system} or null;
  isLinuxX86_64 = system == "x86_64-linux";
in
  lib.throwIfNot (source != null && binaryName != null) "jcode: unsupported system ${system}"
  stdenvNoCC.mkDerivation (_finalAttrs: {
    pname = "jcode";
    version = lib.removePrefix "v" source.version;
    inherit (source) src;

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
      test -x ${binaryName}
      install -Dm755 ${binaryName} $out/bin/jcode
      ${lib.optionalString isLinuxX86_64 ''
        # The launcher resolves this payload and any bundled libraries relative to itself.
        test -x ${binaryName}.bin
        install -Dm755 ${binaryName}.bin $out/bin/${binaryName}.bin
        for library in libssl.so* libcrypto.so*; do
          if [ -e "$library" ]; then
            cp -P "$library" $out/bin/
          fi
        done
      ''}
      runHook postInstall
    '';

    meta = with lib; {
      description = "Fast, resource-efficient terminal coding agent";
      homepage = "https://github.com/1jehuang/jcode";
      license = licenses.mit;
      maintainers = with maintainers; [DivitMittal];
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      mainProgram = "jcode";
      sourceProvenance = [sourceTypes.binaryNativeCode];
    };
  })
