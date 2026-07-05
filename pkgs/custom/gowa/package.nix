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

    vendorHash = "sha256-56657X+GJGc5F8Bycfw03vmX3mrr6PslmMLa9vUo7mE=";

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
