{
  lib,
  buildGoModule,
  sources,
}: let
  inherit (sources.gowa) version src;
in
  buildGoModule {
    pname = "go-whatsapp-web-multidevice";
    inherit version src;

    sourceRoot = "${src.name}/src";

    vendorHash = "sha256-CHcVetvMDSzKM2I/jX4+kL2Q7h5E/BOGWl8wJV1dzcg=";

    ldflags = ["-s" "-w" "-X github.com/aldinokemal/go-whatsapp-web-multidevice/config.AppVersion=${version}"];

    preBuild = ''
      ls -la views/ || echo "Views directory check"
    '';

    postInstall = ''
      mv $out/bin/go-whatsapp-web-multidevice $out/bin/gowa
    '';

    meta = {
      description = "WhatsApp REST API with support for UI, Webhooks, and MCP. Built with Golang for efficient memory use";
      homepage = "https://github.com/aldinokemal/go-whatsapp-web-multidevice";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [DivitMittal];
      platforms = lib.platforms.unix;
      mainProgram = "gowa";
    };
  }
