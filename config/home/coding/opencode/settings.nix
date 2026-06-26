_: {
  programs.opencode.settings = {
    autoupdate = false;
    autoshare = false;

    plugin = [
      "opencode-antigravity-auth@beta"
      "opencode-beads"
      "opencode-pty"
    ];
  };
}
