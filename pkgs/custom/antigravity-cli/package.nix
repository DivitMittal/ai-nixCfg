{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "antigravity-cli";
  version = "1.5.16";

  # nixpkgs-26.05-darwin has no CLI package, and unstable omits Intel macOS.
  # Pin the native release published by Google's CLI installer manifest.
  src = fetchurl {
    url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.16-5250855658717184/darwin-x64/cli_mac_x64.tar.gz";
    hash = "sha512-s+rgc+5jMDLp1HPNx3JcML3+LglDa8Ns+zQi5+X6NzPelZGn940CNiKU57+H40XXDl2DlonlJhKabz/AQYV6BQ==";
  };

  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 antigravity $out/bin/agy
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/agy --version | grep -F "$version"
    runHook postInstallCheck
  '';

  meta = {
    description = "Google's terminal user interface agent client for Intel macOS";
    homepage = "https://antigravity.google";
    license = lib.licenses.unfree;
    platforms = ["x86_64-darwin"];
    mainProgram = "agy";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}
