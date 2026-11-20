{
  lib,
  buildGoModule,
  sources,
}: let
  inherit (sources.zai) version src;
in
  buildGoModule {
    pname = "zai";
    inherit version src;

    vendorHash = "sha256-xeO1/VNvezkCeeQ5EIFHQ3ZW32RIfQ2UFgDFIVww+sc=";

    ldflags = [
      "-s"
      "-w"
      "-X github.com/dotcommander/zai/internal/version.Version=${version}"
    ];

    meta = {
      description = "CLI for Z.AI GLM models — chat, search, vision, image, audio, video, TTS, embeddings";
      homepage = "https://github.com/dotcommander/zai";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [DivitMittal];
      platforms = lib.platforms.unix;
      mainProgram = "zai";
    };
  }
