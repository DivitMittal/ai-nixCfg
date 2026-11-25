{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.claude-code;
in {
  home.sessionVariables.DISABLE_AUTOUPDATER = "1";

  home.file."${cfg.configDir}/keybindings.json".source = lib.mkIf cfg.enable (
    (pkgs.formats.json {}).generate "claude-code-keybindings.json" {
      bindings = [
        # Leave arrows alone in the composer and pickers. Ctrl+G opens
        # $VISUAL/$EDITOR for Vim-Cfg's normal-mode U/R undo/redo.
        {
          context = "Scroll";
          bindings = {
            "alt+up" = "scroll:lineUp";
            "alt+down" = "scroll:lineDown";
          };
        }
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
