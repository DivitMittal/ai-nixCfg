{
  lib,
  stdenvNoCC,
  rustPlatform,
  autoPatchelfHook,
  glibc,
  gcc-unwrapped,
  makeWrapper,
  fd,
  ripgrep,
  sources,
  fetchFromGitHub,
}: let
  system = stdenvNoCC.hostPlatform.system;
  source = sources.${"pi-agent-rust-${system}"} or null;
  archiveEntries = {
    aarch64-darwin = "pi-darwin-arm64";
    x86_64-linux = "pi-linux-amd64";
  };
  archiveEntry = archiveEntries.${system} or null;
  isLinux = stdenvNoCC.hostPlatform.isLinux;
  isDarwinX86 = system == "x86_64-darwin";

  # Upstream only publishes aarch64-darwin and x86_64-linux prebuilt binaries.
  # On x86_64-darwin we fall back to building from a pinned GitHub source.
  srcBuildFromGit = fetchFromGitHub {
    owner = "Dicklesworthstone";
    repo = "pi_agent_rust";
    rev = "v0.1.23";
    hash = "sha256-zifnkV5kjEBlAwmRY6Lk7N46NZY5jx/xxofHY32F6UE=";
  };

  # Short-circuit with a helpful error on systems we don't support.
  _ = lib.throwIfNot (source != null && archiveEntry != null || isDarwinX86)
    "pi-agent-rust: unsupported system ${system}";

  # The x86_64-darwin branch builds from source via rustPlatform, then
  # rewraps the resulting `pi` binary to `pi-rust` so it can coexist with
  # the TypeScript `pi` package from `pi-nix` in the same Home Manager
  # profile.
  rewrittenSourceBuild = stdenvNoCC.mkDerivation {
    pname = "pi-agent-rust";
    version = "0.1.23";
    src = rustPlatform.buildRustPackage {
      pname = "pi-agent-rust";
      version = "0.1.23";
      src = srcBuildFromGit;
      cargoLock = {
        lockFile = "${srcBuildFromGit}/Cargo.lock";
      };
      cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      doCheck = false;
      meta = {
        description = "Dicklesworthstone's Rust port of the Pi coding agent CLI (built from source on x86_64-darwin)";
        homepage = "https://github.com/Dicklesworthstone/pi_agent_rust";
        license = lib.licenses.unfree;
        mainProgram = "pi-rust";
      };
    };
    nativeBuildInputs = [makeWrapper];
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp -r $src/bin/. $out/bin/
      mv $out/bin/pi $out/bin/pi-rust
      for tool in pi-rust; do
        wrapProgram $out/bin/$tool \
          --prefix PATH : ${lib.makeBinPath [fd ripgrep]}
      done
      runHook postInstall
    '';
    meta = {
      description = "Dicklesworthstone's Rust port of the Pi coding agent CLI (built from source on x86_64-darwin)";
      homepage = "https://github.com/Dicklesworthstone/pi_agent_rust";
      license = lib.licenses.unfree;
      mainProgram = "pi-rust";
    };
  };

  prebuiltDerivation = stdenvNoCC.mkDerivation (_finalAttrs: {
    pname = "pi-agent-rust";
    version = lib.removePrefix "v" source.version;
    inherit (source) src;

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = lib.optionals isLinux [autoPatchelfHook makeWrapper];
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
      platforms = ["aarch64-darwin" "x86_64-linux"];
      mainProgram = "pi-rust";
      sourceProvenance = [sourceTypes.binaryNativeCode];
    };
  });
in
  if isDarwinX86 then rewrittenSourceBuild else prebuiltDerivation
