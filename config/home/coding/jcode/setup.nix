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

      # Yazi preview scrolling and Vim-Cfg smart-splits focus.
      keybindings = {
        scroll_up = "alt+up";
        scroll_down = "alt+down";
        speed_increase = "ctrl+alt+up";
        speed_decrease = "ctrl+alt+down";
        scroll_page_up = "pageup";
        scroll_page_down = "pagedown";
        scroll_prompt_up = "alt+shift+up";
        scroll_prompt_down = "alt+shift+down";
        workspace_left = "ctrl+left";
        workspace_down = "ctrl+down";
        workspace_up = "ctrl+up";
        workspace_right = "ctrl+right";
      };
    };

    providerSettings = {
      lappkart = "JCODE_PROVIDER_LAPPKART_API_KEY";
    };
  };
}
