_: {
  # Upstream home-manager provides programs.t3code (package defaults to
  # `pkgs.t3code or null`, so enabling without the package is safe).
  programs.t3code = {
    enable = true;
  };
}
