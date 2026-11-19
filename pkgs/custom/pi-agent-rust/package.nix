{
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  glibc,
  gcc-unwrapped,
  makeWrapper,
  fd,
  ripgrep,
  sources,
}: let
  system = stdenvNoCC.hostPlatform.system;
  source = sources.${"pi-agent-rust-${system}"} or null;
  ## Release tarballs (v0.7+) hold a single `pi` binary on every platform
  archiveEntry = "pi";
  isLinux = stdenvNoCC.hostPlatform.isLinux;
  prebuiltDerivation = stdenvNoCC.mkDerivation (_finalAttrs: {
    pname = "pi-agent-rust";
    version = lib.removePrefix "v" source.version;
    inherit (source) src;

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [makeWrapper] ++ lib.optionals isLinux [autoPatchelfHook];
    buildInputs = lib.optionals isLinux [
      glibc
      gcc-unwrapped.lib
    ];

    installPhase = ''
      runHook preInstall
      test -x ${archiveEntry}
      install -Dm755 ${archiveEntry} $out/bin/pi-rust
      # Upstream README requires `fd` and `rg` on PATH. Use makeBinaryWrapper
      # so the wrapper itself lands in $out/bin (not the unwrapped binary).
      for tool in pi-rust; do
        wrapProgram $out/bin/$tool \
          --prefix PATH : ${lib.makeBinPath [fd ripgrep]}
      done
      runHook postInstall
    '';

    meta = with lib; {
      description = "Dicklesworthstone's Rust port of the Pi coding agent CLI";
      longDescription = ''
        Sub-100ms-startup Rust reimplementation of the Pi coding agent.
        Exposed as `pi-rust` so it can coexist with the TypeScript Pi
        package from `pi-nix` in the same Home Manager profile.
      '';
      homepage = "https://github.com/Dicklesworthstone/pi_agent_rust";
      # Custom "MIT + OpenAI/Anthropic rider" — not plain MIT; conservative
      # declaration to avoid public binary cache redistribution.
      license = licenses.unfree;
      maintainers = with maintainers; [DivitMittal];
      platforms = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux"];
      mainProgram = "pi-rust";
      sourceProvenance = [sourceTypes.binaryNativeCode];
    };
  });
in
  lib.throwIfNot (source != null) "pi-agent-rust: unsupported system ${system}" prebuiltDerivation
