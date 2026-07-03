{
  pkgs,
  ai-nixCfg,
  ...
}: {
  programs.herdr = {
    enable = true;
    settings = {
      theme.name = "terminal";
      terminal.shell_mode = "auto";
    };
  };

  services.kolu = {
    enable = true;
    package = ai-nixCfg.inputs.kolu.packages.${pkgs.stdenv.hostPlatform.system}.koluBin;
  };
}
