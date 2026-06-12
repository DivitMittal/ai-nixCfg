_: {
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

  services.kolu.enable = true;
}
