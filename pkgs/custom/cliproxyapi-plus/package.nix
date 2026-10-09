{
  lib,
  stdenvNoCC,
  sources,
}: let
  system = stdenvNoCC.hostPlatform.system;
  source = sources.${"cliproxyapi-plus-${system}"} or null;

  # Maps Nix system tuple to the binary inside the upstream tarball.
  binaryNames = {
    x86_64-linux = "cli-proxy-api-plus";
    aarch64-linux = "cli-proxy-api-plus";
    x86_64-darwin = "cli-proxy-api-plus";
    aarch64-darwin = "cli-proxy-api-plus";
  };
  binaryName = binaryNames.${system} or null;
in
  lib.throwIfNot (source != null && binaryName != null) "cliproxyapi-plus: unsupported system ${system}"
  stdenvNoCC.mkDerivation (_finalAttrs: {
    pname = "cliproxyapi-plus";
    version = lib.removePrefix "v" source.version;
    inherit (source) src;

    # The upstream tarball flattens the binary to the archive root; strip the
    # top-level directory that nvfetcher preserves from the GitHub tarball.
    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      test -x ${binaryName}
      install -Dm755 ${binaryName} $out/bin/${binaryName}
      runHook postInstall
    '';

    meta = with lib; {
      description = "Local Anthropic/OpenAI-compatible proxy for CLI OAuth accounts and custom providers (CCS fork of CLIProxyAPI)";
      homepage = "https://github.com/kaitranntt/CLIProxyAPIPlus";
      license = licenses.mit;
      maintainers = with maintainers; [DivitMittal];
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      mainProgram = "cli-proxy-api-plus";
      sourceProvenance = [sourceTypes.binaryNativeCode];
    };
  })