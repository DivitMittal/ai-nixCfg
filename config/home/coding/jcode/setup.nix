{
  pkgs,
  ai-nixCfg,
  ...
}: {
  programs.jcode = {
    enable = true;
    package = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system}.jcode;

    settings = {
      features.check_updates = false; # Updates come from the Nix package pin.

      # Use TLTR's TL layer for transcript movement.
      # Plain arrows and Ctrl+Up/Down remain available for editing and history.
      keybindings = {
        scroll_up = "ctrl+shift+up";
        scroll_down = "ctrl+shift+down";
        scroll_page_up = "pageup";
        scroll_page_down = "pagedown";
        scroll_prompt_up = "alt+shift+up";
        scroll_prompt_down = "alt+shift+down";
        # The Colemak base keys at the TL arrow positions are n/e/u/i.
        # Keep the arrow aliases and leave Alt+N and Alt+I to their panels.
        workspace_left = "ctrl+alt+n, ctrl+alt+left";
        workspace_down = "ctrl+alt+e, ctrl+alt+down";
        workspace_up = "ctrl+alt+u, ctrl+alt+up";
        workspace_right = "ctrl+alt+i, ctrl+alt+right";
      };
    };
  };
}
