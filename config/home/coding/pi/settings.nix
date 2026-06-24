{config, ...}: {
  programs.pi.coding-agent.settings = {
    general = {
      preferredEditor = "${config.home.sessionVariables.EDITOR}";
      vimMode = true;
      enableAutoUpdate = false;
    };
    ui = {
      theme = "ANSI";
    };
    session = {
      retention = {
        enabled = true;
        maxAge = "30d";
      };
    };
  };
}
