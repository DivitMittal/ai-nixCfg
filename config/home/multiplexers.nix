{
  pkgs,
  ai-nixCfg,
  ...
}: {
  programs.herdr = {
    enable = true;
    # Use llm-agents' herdr package — nixpkgs doesn't ship herdr.
    package = ai-nixCfg.inputs.llm-agents.packages.${pkgs.stdenvNoCC.hostPlatform.system}.herdr;
    settings = {
      keys.prefix = "ctrl+a";

      # Tab actions: mnemonic letter under the inner-mux prefix.
      keys.new_tab = "prefix+c";
      keys.rename_tab = "prefix+r";
      keys.close_tab = "prefix+d";
      keys.next_tab = "prefix+n";
      keys.previous_tab = "prefix+p";
      keys.switch_tab = "prefix+1..9";

      # Workspace actions: shift marks the workspace scope.
      keys.new_workspace = "prefix+shift+c";
      keys.rename_workspace = "prefix+shift+r";
      keys.close_workspace = "prefix+shift+d";
      keys.next_workspace = "prefix+shift+n";
      keys.previous_workspace = "prefix+shift+p";
      keys.switch_workspace = "prefix+shift+1..9";

      # Agents are a herdr-only concept; keep them off the arrow keys reserved
      # for WezTerm/smart-splits interop.
      keys.focus_agent = "alt+1..9";

      # Pane focus uses prefix + arrows so bare Ctrl/Alt arrows remain owned by
      # WezTerm + Neovim smart-splits.
      keys.focus_pane_left = "prefix+left";
      keys.focus_pane_down = "prefix+down";
      keys.focus_pane_up = "prefix+up";
      keys.focus_pane_right = "prefix+right";
      keys.cycle_pane_next = "prefix+tab";
      keys.cycle_pane_previous = "prefix+shift+tab";

      theme.name = "terminal";
      terminal.shell_mode = "auto";
      ui.show_agent_labels_on_pane_borders = true;
      ui.sound.enabled = true;
      ui.toast.delivery = "system";
    };
  };

  services.kolu = {
    enable = true;
    package = ai-nixCfg.inputs.kolu.packages.${pkgs.stdenvNoCC.hostPlatform.system}.koluBin;
  };
}
