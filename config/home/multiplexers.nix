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

      # --- Navigation (direct, no prefix needed) ---

      # Tabs: alt + horizontal
      keys.previous_tab = "alt+left";
      keys.next_tab = "alt+right";

      # Workspaces: alt + vertical
      keys.previous_workspace = "alt+up";
      keys.next_workspace = "alt+down";
      keys.switch_workspace = "prefix+shift+1..9";

      # Panes: ctrl + arrows
      keys.focus_pane_left = "ctrl+left";
      keys.focus_pane_down = "ctrl+down";
      keys.focus_pane_up = "ctrl+up";
      keys.focus_pane_right = "ctrl+right";
      keys.cycle_pane_next = "ctrl+tab";
      keys.cycle_pane_previous = "ctrl+shift+tab";

      # Agents: alt layer
      keys.focus_agent = "alt+1..9";
    };
  };

  services.kolu = {
    enable = true;
    package = ai-nixCfg.inputs.kolu.packages.${pkgs.stdenvNoCC.hostPlatform.system}.koluBin;
  };
}
