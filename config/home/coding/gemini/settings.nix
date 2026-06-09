{config, ...}: {
  programs.gemini-cli.settings = {
    general = {
      preferredEditor = "${config.home.sessionVariables.EDITOR}";
      vimMode = true;
      previewFeatures = true;
      enableAutoUpdate = false;
      enablePromptCompletion = true;
      sessionRetention = {
        enabled = true;
        maxAge = "30d";
        warningAcknowledged = true;
      };
    };
    security = {
      auth = {
        selectedType = "oauth-personal";
      };
    };
    ui = {
      theme = "ANSI";
      showStatusInTitle = true;
      footer = {
        hideContextPercentage = false;
      };
      showModelInfoInChat = true;
      showCitations = true;
      showMemoryUsage = true;
    };
    context = {
      loadMemoryFromIncludeDirectories = true;
    };
    tools = {
      shell = {
        showColor = true;
      };
    };
  };
}
