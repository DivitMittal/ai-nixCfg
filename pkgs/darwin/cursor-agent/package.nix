{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  coreutils,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cursor-agent";
  version = "2026.11.13-eacade1";

  src = fetchurl {
    url = "https://downloads.cursor.com/lab/${finalAttrs.version}/darwin/x64/agent-cli-package.tar.gz";
    hash = "sha256-uoa3wOp+RW+dMyMunh6/bKxWqsNr6imf222i1NiragA=";
  };

  nativeBuildInputs = [makeWrapper];
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/share/cursor-agent"
    cp -R . "$out/share/cursor-agent"
    makeWrapper "$out/share/cursor-agent/cursor-agent" "$out/bin/cursor-agent" \
      --prefix PATH : "$out/share/cursor-agent:${coreutils}/bin"

    runHook postInstall
  '';

  meta = {
    description = "Cursor's interactive terminal coding agent";
    homepage = "https://cursor.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = ["x86_64-darwin"];
    mainProgram = "cursor-agent";
  };
})
