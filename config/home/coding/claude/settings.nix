{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.claude-code;
  vertical = context: up: down: {
    inherit context;
    bindings = {
      inherit up down;
      "ctrl+alt+u" = up;
      "ctrl+alt+e" = down;
    };
  };
in {
  home.sessionVariables.DISABLE_AUTOUPDATER = "1";

  home.file."${cfg.configDir}/keybindings.json".source = lib.mkIf cfg.enable (
    (pkgs.formats.json {}).generate "claude-code-keybindings.json" {
      bindings = [
        # Horizontal movement in the composer is native to the text editor.
        # Leave Left/Right untouched: there are no bindable cursor actions.
        (vertical "Chat" "history:previous" "history:next")
        (vertical "Autocomplete" "autocomplete:previous" "autocomplete:next")
        (vertical "Select" "select:previous" "select:next")
        (vertical "Settings" "select:previous" "select:next")
        (vertical "Confirmation" "confirm:previous" "confirm:next")
        (vertical "MessageSelector" "messageSelector:up" "messageSelector:down")
      ];
    }
  );

  programs.claude-code.settings = {
    voiceEnabled = true;
    skipDangerousModePermissionPrompt = true;
    claudeInChromeDefaultEnabled = false;
    attribution = {
      commit = "";
      pr = "";
    };
  };
}
