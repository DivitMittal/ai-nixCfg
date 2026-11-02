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
  isLinux = stdenvNoCC.hostPlatform.isLinux;
in
  lib.throwIfNot (source != null) "pi-agent-rust: unsupported system ${system}"
  stdenvNoCC.mkDerivation (_finalAttrs: {
    pname = "pi-agent-rust";
    version = lib.removePrefix "v" source.version;
    inherit (source) src;

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [makeWrapper] ++ lib.optional isLinux autoPatchelfHook;
    buildInputs = lib.optionals isLinux [
      glibc
      gcc-unwrapped.lib
    ];

    # Upstream requires `fd` and `rg` on PATH. Installed as `pi-rust` so it can
    # coexist with the TypeScript `pi` in one Home Manager profile.
    installPhase = ''
      runHook preInstall
      install -Dm755 pi $out/bin/pi-rust
      wrapProgram $out/bin/pi-rust --prefix PATH : ${lib.makeBinPath [fd ripgrep]}
      runHook postInstall
    '';

    meta = with lib; {
      description = "Dicklesworthstone's Rust port of the Pi coding agent CLI";
      longDescription = ''
        Sub-100ms-startup Rust reimplementation of the Pi coding agent.
        Exposed as `pi-rust` so it can coexist with the TypeScript Pi
        package in the same Home Manager profile.
      '';
      homepage = "https://github.com/Dicklesworthstone/pi_agent_rust";
      # Custom "MIT + OpenAI/Anthropic rider" — not plain MIT; conservative
      # declaration to avoid public binary cache redistribution.
      license = licenses.unfree;
      maintainers = with maintainers; [DivitMittal];
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      mainProgram = "pi-rust";
      sourceProvenance = [sourceTypes.binaryNativeCode];
    };
  })
