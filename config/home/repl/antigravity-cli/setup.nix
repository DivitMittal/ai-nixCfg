{lib, ...}: {
  programs.antigravity-cli = {
    enable = true;
    # The CLI ships with the Antigravity IDE (installed via brewCask on
    # darwin in config/home/gui.nix). nixpkgs now provides antigravity-cli, so
    # force null to override the upstream default and avoid pulling the package.
    package = lib.mkForce null;
  };
}
