{
  config,
  pkgs,
  ...
}: let
  jsonFormat = pkgs.formats.json {};
in {
  home.file.".pi/agent/settings.json".source = jsonFormat.generate "pi-settings.json" {
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
