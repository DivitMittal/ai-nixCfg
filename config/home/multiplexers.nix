{
  pkgs,
  ai-nixCfg,
  ...
}: {
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

  programs.agent-deck = {
    enable = true;
    settings = {
      default_tool = "claude";
      # The binary is pinned by Nix, so disable the in-app updater entirely —
      # it must never install a build that diverges from the flake.
      updates.auto_update = false;
      updates.check_enabled = false;
      ui.footer = "compact";
    };
  };

  services.kolu = {
    enable = true;
    package = ai-nixCfg.inputs.kolu.packages.${pkgs.stdenv.hostPlatform.system}.koluBin;
  };
}
