_: {
  # Permissions are written into config.json via the upstream settings option.
  programs.github-copilot-cli.settings.permissions = {
    allow = [];
    defaultMode = "acceptEdits";
    deny = [
      "WebFetch"
    ];
  };
}
