{
  lib,
  stdenvNoCC,
  makeWrapper,
  sources,
}: let
  # nvfetcher tracks one entry per platform release archive; select by current system.
  source = sources.${"higgsfield-cli-${stdenvNoCC.hostPlatform.system}"} or null;
in
  lib.throwIfNot (source != null) "higgsfield-cli: unsupported system ${stdenvNoCC.hostPlatform.system}"
  stdenvNoCC.mkDerivation (_finalAttrs: {
    pname = "higgsfield-cli";
    inherit (source) version src;

    sourceRoot = ".";

    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [makeWrapper];

    # Upstream's primary name is `hf`, which collides with Hugging Face's CLI
    # (config/home/cloud.nix), so only the `higgsfield`/`higgs` aliases are
    # exposed. The store copy can't self-update and shouldn't phone home.
    installPhase = ''
      runHook preInstall
      install -Dm755 hf "$out/libexec/higgsfield/hf"
      for name in higgsfield higgs; do
        makeWrapper "$out/libexec/higgsfield/hf" "$out/bin/$name" \
          --set-default HIGGSFIELD_NO_UPDATE_CHECK 1 \
          --set-default HIGGSFIELD_DISABLE_TELEMETRY 1 \
          --set-default HIGGSFIELD_INSTALL_METHOD nix
      done
      runHook postInstall
    '';

    meta = {
      description = "Higgsfield AI CLI: generate images and videos from the terminal";
      homepage = "https://github.com/higgsfield-ai/cli";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [DivitMittal];
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      mainProgram = "higgsfield";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  })
