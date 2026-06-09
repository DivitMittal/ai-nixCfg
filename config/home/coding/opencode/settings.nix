_: {
  programs.opencode.settings = {
    autoupdate = false;
    autoshare = false;

    plugin = [
      "oh-my-opencode"
      "opencode-antigravity-auth@beta"
      "opencode-beads"
      "opencode-pty"
    ];
  };
}
