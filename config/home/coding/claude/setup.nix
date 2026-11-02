{
  pkgs,
  customLib,
  ...
}: {
  programs.claude-code = {
    enable = true;
    package = customLib.mkBunxBin pkgs "claude" "@anthropic-ai/claude-code@latest";
  };
}
