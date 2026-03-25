_: {
  home.sessionVariables.DISABLE_AUTOUPDATER = "1";

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
