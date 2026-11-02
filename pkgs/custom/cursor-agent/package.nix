{
  lib,
  stdenvNoCC,
  sources,
}: let
  system = stdenvNoCC.hostPlatform.system;
  source = sources.${"cursor-agent-${system}"} or null;
in
  lib.throwIfNot (source != null) "cursor-agent: unsupported system ${system}"
  stdenvNoCC.mkDerivation (_finalAttrs: {
    pname = "cursor-agent";
    inherit (source) version src;

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;
    # The bundle ships signed Mach-O helpers and .node addons that fixup would
    # invalidate.
    dontFixup = true;

    # The launcher resolves its bundled node and index.js relative to itself,
    # so the tree stays intact and bin/ only holds symlinks into it.
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib $out/bin
      cp -R dist-package $out/lib/cursor-agent
      ln -s $out/lib/cursor-agent/cursor-agent $out/bin/cursor-agent
      runHook postInstall
    '';

    meta = with lib; {
      description = "Cursor CLI coding agent (vendor tarball)";
      homepage = "https://cursor.com/cli";
      license = licenses.unfree;
      maintainers = with maintainers; [DivitMittal];
      platforms = ["x86_64-darwin"];
      mainProgram = "cursor-agent";
      sourceProvenance = [sourceTypes.binaryNativeCode];
    };
  })
