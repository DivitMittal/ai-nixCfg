{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}: let
  version = "0.15.2";
  pname = "bv";

  sources = {
    "x86_64-linux" = {
      url = "https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_linux_amd64.tar.gz";
      hash = "sha256-Rnx97nLFmekV1jjrIjNakeuEIXHt3C57r0MSkFinZk4=";
    };
    "aarch64-linux" = {
      url = "https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_linux_arm64.tar.gz";
      hash = "sha256-S8mzJ87dVLCLVcRFNiunQBfMiuQFMLpvBFG4ZrR0Qb4=";
    };
    "x86_64-darwin" = {
      url = "https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_darwin_amd64.tar.gz";
      hash = "sha256-DR0YawziAZ32d2TQcannqgLNOQMs9qD2PPKcpKOG99I=";
    };
    "aarch64-darwin" = {
      url = "https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_darwin_arm64.tar.gz";
      hash = "sha256-Tt2XL7eLf4dZRD70iW0/6HQBb8dPrpcGszfZMixP4ss=";
    };
  };

  platformSource = sources.${stdenvNoCC.hostPlatform.system} or (throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}");
in
  stdenvNoCC.mkDerivation {
    inherit pname version;

    src = fetchurl {
      inherit (platformSource) url hash;
    };

    sourceRoot = ".";

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 bv $out/bin/bv

      runHook postInstall
    '';

    meta = {
      description = "Graph-aware task management TUI for beads projects";
      homepage = "https://github.com/Dicklesworthstone/beads_viewer";
      license = lib.licenses.mit;
      platforms = lib.attrNames sources;
      maintainers = with lib.maintainers; [DivitMittal];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      mainProgram = "bv";
    };
  }
