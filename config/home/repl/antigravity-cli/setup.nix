_: {
  programs.antigravity-cli = {
    enable = true;
    # The CLI ships with the Antigravity IDE (installed via brewCask on
    # darwin in config/home/gui.nix); no standalone nixpkgs package exists yet.
    package = null;
  };
}
