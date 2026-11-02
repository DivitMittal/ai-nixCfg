{
  lib,
  stdenvNoCC,
  sources,
}: let
  system = stdenvNoCC.hostPlatform.system;
  source = sources.${"antigravity-cli-${system}"} or null;
in
  lib.throwIfNot (source != null) "antigravity-cli: unsupported system ${system}"
  stdenvNoCC.mkDerivation (_finalAttrs: {
    pname = "antigravity-cli";
    inherit (source) version src;

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;
    # Vendor-signed Mach-O; stripping would invalidate the signature.
    dontFixup = true;

    # The tarball's `antigravity` is what the Homebrew cask exposes as `agy`.
    installPhase = ''
      runHook preInstall
      install -Dm755 antigravity $out/bin/agy
      ln -s agy $out/bin/antigravity
      runHook postInstall
    '';

    meta = with lib; {
      description = "CLI for Google Antigravity (vendor tarball)";
      homepage = "https://antigravity.google/";
      license = licenses.unfree;
      maintainers = with maintainers; [DivitMittal];
      platforms = ["x86_64-darwin"];
      mainProgram = "agy";
      sourceProvenance = [sourceTypes.binaryNativeCode];
    };
  })
