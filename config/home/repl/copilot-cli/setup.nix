{pkgs, ...}: {
  programs.github-copilot-cli = {
    enable = false;
    package = pkgs.github-copilot-cli;
  };
}
