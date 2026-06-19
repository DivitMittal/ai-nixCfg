{ pkgs, ai-nixCfg, ... }: {
  programs.workmux = {
    enable = true;
    settings = {
      nerdfont = true;
      theme.mode = "dark";
    };
  };

  programs.herdr = {
    enable = true;
    settings = {
      terminal.shell_mode = "auto";
    };
  };

  programs.agent-deck.enable = true;

  services.kolu = {
    enable = true;
    package = ai-nixCfg.inputs.kolu.packages.${pkgs.stdenv.hostPlatform.system}.koluBin;
  };
}
