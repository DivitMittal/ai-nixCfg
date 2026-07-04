{
  pkgs,
  ai-nixCfg,
  ...
}: {
  programs.herdr = {
    enable = true;
    settings = {
      keys.prefix = "ctrl+a";
      theme.name = "terminal";
      terminal.shell_mode = "auto";
      ui.show_agent_labels_on_pane_borders = true;
      ui.sound.enabled = true;
      ui.toast.delivery = "system";
    };
  };

  services.kolu = {
    enable = true;
    package = ai-nixCfg.inputs.kolu.packages.${pkgs.stdenv.hostPlatform.system}.koluBin;
  };
}
