{lib, ...}: {
  programs.opencode.tui = {
    theme = lib.mkForce "ultraviolet";
    keybinds = {
      leader = "ctrl+x";
    };
    scroll_speed = 3;
    scroll_acceleration = {
      enabled = true;
    };
    diff_style = "auto";
  };
}
