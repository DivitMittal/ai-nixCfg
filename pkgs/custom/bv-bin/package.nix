{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}: let
  version = "0.14.4";
  pname = "bv";

  sources = {
    "x86_64-linux" = {
      url = "https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_linux_amd64.tar.gz";
      hash = "sha256-mRUbElaR+cuMLH6Hcc+W4HNJGMv/aXHWV4VUGBuAcTw=";
    };
    "aarch64-linux" = {
      url = "https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_linux_arm64.tar.gz";
      hash = "sha256-qoKInYG0pzCr5XGmHVOLUXNWAcWK69piMf+R0aKVG1g=";
    };
    "x86_64-darwin" = {
      url = "https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_darwin_amd64.tar.gz";
      hash = "sha256-CpOMVjuq170fUMC0RQXIY6/WaV7vq1A89VSmUjOknDk=";
    };
    "aarch64-darwin" = {
      url = "https://github.com/Dicklesworthstone/beads_viewer/releases/download/v${version}/bv_${version}_darwin_arm64.tar.gz";
      hash = "sha256-C3CZCxo4/+anDpqyzOPDU2N9wTfYvd/6gh+oT3em+jE=";
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
