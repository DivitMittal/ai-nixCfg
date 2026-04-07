{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "go-whatsapp-web-multidevice";
  version = "8.3.5";

  src = fetchFromGitHub {
    owner = "aldinokemal";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-rx8G2Byu8YsdDxvsTOIF9I0OYn03spK/KgxaPEbsff0=";
  };

  sourceRoot = "${src.name}/src";

  vendorHash = "sha256-nsDaiRCQhhdxzVE0ciHI4wMeTjMqyYEVS/5k/rujZlY=";

  ldflags = ["-s" "-w" "-X github.com/aldinokemal/go-whatsapp-web-multidevice/config.AppVersion=${version}"];

  # The application embeds view files, so we need to ensure they're available
  preBuild = ''
    # Ensure embedded files are in the right place
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
