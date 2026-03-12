_: {
  home.sessionVariables.DISABLE_AUTOUPDATER = "1";

  programs.claude-code.settings = {
    voiceEnabled = true;
    skipDangerousModePermissionPrompt = true;
    attribution = {
      commit = "";
      pr = "";
    };
  };
}
