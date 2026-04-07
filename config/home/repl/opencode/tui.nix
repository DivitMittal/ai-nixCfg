{
  config,
  pkgs,
  ...
}: let
  jsonFormat = pkgs.formats.json {};
in {
  xdg.configFile."opencode/tui.json" = {
    inherit (config.programs.opencode) enable;
    source = jsonFormat.generate "tui.json" {
      "$schema" = "https://opencode.ai/tui.json";
      theme = "ultraviolet";
      keybinds = {
        leader = "ctrl+x";
      };
      scroll_speed = 3;
      scroll_acceleration = {
        enabled = true;
      };
      diff_style = "auto";
    };
  };
}
